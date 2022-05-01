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
}

class ApplePayHandler: NSObject, ApplePayHandlerProtocol {
    
    let networkService: NetworkServiceProtocol
    
    override init() {
        self.networkService = NetworkService(timeout: 25)
    }
    
    // TODO organise
    var paymentStatus: PKPaymentAuthorizationStatus = .failure
    var paymentIntent: DojoPaymentIntent?
    var payload: DojoApplePayPayload?
    var completion: ((Int) -> Void)?
    
    // needs to be shared so apple pay can receive delegate notifications
    static let shared = ApplePayHandler()
    
    func handleApplePay(paymentIntent: DojoPaymentIntent,
                        payload: DojoApplePayPayload,
                        fromViewController: UIViewController,
                        completion: ((Int) -> Void)?) {
        
        self.paymentIntent = paymentIntent
        self.completion = completion
        self.payload = payload
        var paymentSummaryItems = [PKPaymentSummaryItem]()
        
        //TODO check if ApplePay is avaialbe
        let amount = PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(mantissa: paymentIntent.totalAmount.value, exponent: -2, isNegative: false), type: .final)

        paymentSummaryItems = [amount];
        
        let supportedNetworks: [PKPaymentNetwork] = [
//            .amex,
//            .masterCard,
            .visa
        ]


        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = "merchant.uk.co.paymentsense.sdk.demo.app"
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "BG"
        paymentRequest.currencyCode = "GBP"
        paymentRequest.requiredShippingContactFields = [.emailAddress]
        paymentRequest.requiredBillingContactFields = [.postalAddress]
        paymentRequest.supportedNetworks = supportedNetworks
        
        

        // Display our payment request
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

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        // perform payment on the server
        // TODO
        
        //TODO send a correct payload
        guard let token = paymentIntent?.clientSessionSecret, let payload = payload else {
            // return that can't perform payment because token or payload is nil
            return
        }
        
        var paymentData: ApplePayDataTokenPaymentData?
        
        do {
            paymentData = try JSONDecoder().decode(ApplePayDataTokenPaymentData.self, from: payment.token.paymentData)
        } catch { print(error) }
        
        guard let paymentData = paymentData else {
            // return that can't perform payment because token or payload is nil
            return
        }
        
        let applePayDataRequest = ApplePayDataRequest(token: ApplePayDataToken(paymentData:paymentData,
                                                                               paymentMethod: ApplePayDataTokenPaymentMethod(displayName: payment.token.paymentMethod.displayName ?? "",
                                                                                                                             network: payment.token.paymentMethod.network?.rawValue ?? "",
                                                                                                                             type: convertPaymentMethodType(payment.token.paymentMethod.type)),
                                                                               transactionIdentifier: payment.token.transactionIdentifier))

        networkService.performApplePayPayment(token: token, payloads: (payload, applePayDataRequest)) { result in
            self.paymentStatus = .failure
            switch result {
            case .result(let status) :
                if status == SDKResponseCode.successful.rawValue {
                    self.paymentStatus = .success
                }
            default:
                break
            }
            completion(self.paymentStatus)
        }
    }
    
    private func convertPaymentMethodType(_ type: PKPaymentMethodType) -> String {
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
}
