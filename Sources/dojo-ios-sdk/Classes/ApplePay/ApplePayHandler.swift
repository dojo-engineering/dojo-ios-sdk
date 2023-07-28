//
//  ApplePayHandler.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 01/05/2022.
//

import Foundation
import PassKit

protocol ApplePayHandlerProtocol {
    func handleApplePay(paymentIntent: DojoPaymentIntent,
                        payload: DojoApplePayPayload,
                        debugConfig: DojoSDKDebugConfig?,
                        fromViewController: UIViewController,
                        completion: ((Int) -> Void)?)
    func canMakeApplePayPayment(config: DojoApplePayConfig) -> Bool
}

class ApplePayHandler: NSObject, ApplePayHandlerProtocol {
    
    private let networkService: NetworkServiceProtocol
    private var paymentStatus: PKPaymentAuthorizationStatus = .failure
    private var paymentIntent: DojoPaymentIntent?
    private var payload: DojoApplePayPayload?
    private var debugConfig: DojoSDKDebugConfig?
    private var completion: ((Int) -> Void)?
    
    // needs to be shared so apple pay can receive delegate notifications
    // TODO check that instance is destroyed
    static let shared = ApplePayHandler()
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func handleApplePay(paymentIntent: DojoPaymentIntent,
                        payload: DojoApplePayPayload,
                        debugConfig: DojoSDKDebugConfig?,
                        fromViewController: UIViewController,
                        completion: ((Int) -> Void)?) {
        
        self.paymentIntent = paymentIntent
        self.completion = completion
        self.payload = payload
        self.debugConfig = debugConfig
        
        //TODO check if ApplePay is avaialbe

        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [getApplePayAmount(paymentIntent.totalAmount.value)]
        paymentRequest.merchantIdentifier = payload.applePayConfig.merchantIdentifier
        paymentRequest.supportedNetworks = getSupportedApplePayNetworks(payload.applePayConfig.supportedCards)
        paymentRequest.merchantCapabilities = getMerchantCapability()
        paymentRequest.countryCode = getCountryCode()
        paymentRequest.currencyCode = paymentIntent.totalAmount.currencyCode
        if payload.applePayConfig.collectBillingAddress {
            paymentRequest.requiredBillingContactFields = [.postalAddress]
        }
        
        if payload.applePayConfig.collectShippingAddress {
            paymentRequest.requiredShippingContactFields = [.postalAddress]
        }
        if payload.applePayConfig.collectEmail {
            paymentRequest.requiredShippingContactFields.insert(.emailAddress)
        }

        // Display payment request
        let paymentController: PKPaymentAuthorizationController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController.delegate = self
        paymentController.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                completion?(DojoSDKResponseCode.declined.rawValue)
             }
         })
      }
    
    func canMakeApplePayPayment(config: DojoApplePayConfig) -> Bool {
        let supportedCardNetworks = getSupportedApplePayNetworks(config.supportedCards)
        guard !supportedCardNetworks.isEmpty else {
            // supported card network is empty, can't present apple pay
            return false
        }
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedCardNetworks)
    }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completion?(DojoSDKResponseCode.successful.rawValue)
                } else {
                    self.completion?(DojoSDKResponseCode.declined.rawValue)
                }
            }
        }
    }
    
    func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        return nil
    }
    
    // Try to refresh token right away before payment?
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Verify that required payment information exists
        guard let paymentIntentId = paymentIntent?.id, let payload = payload,
              let applePayDataRequest = try? convertApplePayPaymentObjectToServerFormat(payment) else {
            // return that can't perform payment because token or payload is nil
            self.paymentStatus = .failure
            completion(self.paymentStatus)
            return
        }
        
        // Starting from iOS 16 the Apple Pay screen is not closed if paymnet failed
        // Because of that we need to refresh the token for every transaction to guarantee that it's valid
        DojoSDK.refreshPaymentIntent(intentId: paymentIntentId, debugConfig: debugConfig) { refreshedIntent, error in
            // Error refreshing token
            if let _ = error {
                completion(self.paymentStatus)
                return
            }
            
            if let data = refreshedIntent?.data(using: .utf8) {
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode(DojoPaymentIntent.self, from: data) {
                    // Decoded token sucessfully
                    
                    // Check if token exists
                    guard let token = decodedResponse.clientSessionSecret else {
                        // Payment token doesn't exist
                        completion(self.paymentStatus)
                        return
                    }
                    // Now try to do the actual payment
                    self.networkService.performApplePayPayment(token: token, payloads: (payload, applePayDataRequest), debugConfig: self.debugConfig) { result in
                        switch result {
                            // payment successded
                        case .result(let status):
                            if status == DojoSDKResponseCode.successful.rawValue {
                                self.paymentStatus = .success
                            }
                        default:
                            break
                        }
                        // notify with the final result of the payment
                        completion(self.paymentStatus)
                    }
                } else {
                    // can't decode new payment intent
                    completion(self.paymentStatus)
                }
            } else {
                // there is no data coming from the server for the new payment intent
                completion(self.paymentStatus)
            }
        }
    }
}

// Helpers
extension ApplePayHandler {
    
    func getCountryCode() -> String {
        "GB"
    }
    
    func getMerchantCapability() -> PKMerchantCapability {
        .capability3DS
    }
    
    func getSupportedApplePayNetworks(_ supportedCards: [ApplePaySupportedCards]) -> [PKPaymentNetwork] {
        let schemas: [PKPaymentNetwork] = supportedCards.compactMap({
            switch $0 {
            case .amex:
                return .amex
            case .maestro:
                if #available(iOS 12.0, *) {
                    return .maestro
                } else {
                    return nil
                }
            case .mastercard:
                return .masterCard
            case .visa:
                return .visa
            }
        })
        return schemas
    }
    
    func getApplePayAmount(_ amount: UInt64) -> PKPaymentSummaryItem {
        PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(mantissa: amount, exponent: -2, isNegative: false), type: .final)
    }
    
    func convertPaymentMethodType(_ type: PKPaymentMethodType) -> String {
        switch type {
        case .credit:
            return "credit"
        case .debit:
            return "debit"
        case .eMoney:
            return "eMoney"
        case .prepaid:
            return "prepaid"
        case .store:
            return "store"
        case .unknown:
            return "unknown"
        }
    }
    
    func convertApplePayPaymentObjectToServerFormat(_ payment: PKPayment) throws -> ApplePayDataRequest {
        let paymentData = try JSONDecoder().decode(ApplePayDataTokenPaymentData.self, from: payment.token.paymentData)
        return ApplePayDataRequest(token: ApplePayDataToken(paymentData:paymentData,
                                                            paymentMethod: ApplePayDataTokenPaymentMethod(displayName: payment.token.paymentMethod.displayName ?? "",
                                                                                                          network: payment.token.paymentMethod.network?.rawValue ?? "",
                                                                                                          type: convertPaymentMethodType(payment.token.paymentMethod.type)),
                                                            transactionIdentifier: payment.token.transactionIdentifier),
                                   billingContact: convertAppleContactToServerContact(payment.billingContact),
                                   shippingContact: convertAppleContactToServerContact(payment.shippingContact))
        
    }
    
    func convertAppleContactToServerContact(_ contact: PKContact?) -> ApplePayAddressContact {
        ApplePayAddressContact(phoneNumber: contact?.phoneNumber?.stringValue,
                               emailAddress: contact?.emailAddress,
                               givenName: contact?.name?.givenName,
                               familyName: contact?.name?.familyName,
                               phoneticGivenName: contact?.name?.phoneticRepresentation?.givenName,
                               phoneticFamilyName: contact?.name?.phoneticRepresentation?.familyName,
                               addressLines: [contact?.postalAddress?.street ?? ""],
                               subLocality: contact?.postalAddress?.subLocality,
                               locality: nil,
                               postalCode: contact?.postalAddress?.postalCode,
                               subAdministrativeArea: contact?.postalAddress?.subAdministrativeArea,
                               administrativeArea: nil,
                               country: contact?.postalAddress?.country,
                               countryCode: contact?.postalAddress?.isoCountryCode)
    }
}
