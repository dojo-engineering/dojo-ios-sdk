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
                        fromViewController: UIViewController,
                        completion: ((Int) -> Void)?)
    func canMakeApplePayPayment() -> Bool
}

class ApplePayHandler: NSObject, ApplePayHandlerProtocol {
    
    private let networkService: NetworkServiceProtocol
    private var paymentStatus: PKPaymentAuthorizationStatus = .failure
    private var paymentIntent: DojoPaymentIntent?
    private var payload: DojoApplePayPayload?
    private var completion: ((Int) -> Void)?
    
    // needs to be shared so apple pay can receive delegate notifications
    // TODO check that instance is destroyed
    static let shared = ApplePayHandler()
    
    override init() {
        self.networkService = NetworkService(timeout: 25)
    }
    
    func handleApplePay(paymentIntent: DojoPaymentIntent,
                        payload: DojoApplePayPayload,
                        fromViewController: UIViewController,
                        completion: ((Int) -> Void)?) {
        
        self.paymentIntent = paymentIntent
        self.completion = completion
        self.payload = payload
        
        //TODO check if ApplePay is avaialbe

        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [getApplePayAmount(paymentIntent.totalAmount.value)]
        paymentRequest.merchantIdentifier = payload.applePayConfig.merchantIdentifier
        paymentRequest.supportedNetworks = getSupportedApplePayNetworks()
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
                completion?(SDKResponseCode.declined.rawValue)
             }
         })
      }
    
    func canMakeApplePayPayment() -> Bool {
        // TODO receive from the payment intent
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: getSupportedApplePayNetworks())
    }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completion?(SDKResponseCode.successful.rawValue)
                } else {
                    self.completion?(SDKResponseCode.declined.rawValue)
                }
            }
        }
    }
    
    func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        return nil
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        //TODO perform payment on the server
        guard let token = paymentIntent?.clientSessionSecret, let payload = payload,
              let applePayDataRequest = try? convertApplePayPaymentObjectToServerFormat(payment) else {
            // return that can't perform payment because token or payload is nil
            self.paymentStatus = .failure
            completion(self.paymentStatus)
            return
        }

        networkService.performApplePayPayment(token: token, payloads: (payload, applePayDataRequest)) { result in
            switch result {
            case .result(let status):
                if status == SDKResponseCode.successful.rawValue {
                    self.paymentStatus = .success
                }
            default:
                break
            }
            completion(self.paymentStatus)
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
    
    func getSupportedApplePayNetworks() -> [PKPaymentNetwork] {
        var schemas: [PKPaymentNetwork] = [.amex, .masterCard, .visa]
        if #available(iOS 12.0, *) {
            schemas.append(.maestro)
        }
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
