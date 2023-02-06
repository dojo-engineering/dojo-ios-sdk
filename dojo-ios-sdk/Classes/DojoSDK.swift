//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

protocol DojoSDKProtocol {
    // Card Payments
    static func executeCardPayment(token: String,
                                   payload: DojoCardPaymentPayload,
                                   fromViewController: UIViewController,
                                   completion: ((Int) -> Void)?)
    static func executeSavedCardPayment(token: String,
                                        payload: DojoSavedCardPaymentPayload,
                                        fromViewController: UIViewController,
                                        completion: ((Int) -> Void)?)
    // Wallet Payments
    static func executeApplePayPayment(paymentIntent: DojoPaymentIntent,
                                       payload: DojoApplePayPayload,
                                       fromViewController: UIViewController,
                                       completion: ((Int) -> Void)?)
    static func isApplePayAvailable(config: DojoApplePayConfig) -> Bool
    // Payment Intent
    static func fetchPaymentIntent(intentId: String, completion: ((String?, Error?) -> Void)?)
    static func refreshPaymentIntent(intentId: String, completion: ((String?, Error?) -> Void)?)
    // Customer Management
    static func fetchCustomerPaymentMethods(customerId: String, customerSecret: String, completion: ((String?, Error?) -> Void)?)
    static func deleteCustomerPaymentMethod(customerId: String, paymentMethodId: String, customerSecret: String, completion: ((Error?) -> Void)?)
}

/// DojoSDK interface
@objc public class DojoSDK: NSObject, DojoSDKProtocol {
    /// Execute card payment
    /// - Parameters:
    ///   - token: Payment secret obtained from a paymentIIntent object.
    ///   - payload: Payment configuration and data.
    ///   - fromViewController: Controller to present 3DS over.
    ///   - completion: Result of the payment.
    public static func executeCardPayment(token: String,
                                          payload: DojoCardPaymentPayload,
                                          fromViewController: UIViewController,
                                          completion: ((Int) -> Void)?) {
        internalExecuteCardPayment(token: token,
                                   payload: payload,
                                   fromViewController: fromViewController,
                                   completion: completion)
    }
    
    /// Execute saved card payment
    /// - Parameters:
    ///   - token: Payment secret obtained from a paymentIIntent object.
    ///   - payload:  Payment configuration and data.
    ///   - fromViewController: Controller to present 3DS over.
    ///   - completion: Result of the payment.
    public static func executeSavedCardPayment(token: String,
                                               payload: DojoSavedCardPaymentPayload,
                                               fromViewController: UIViewController,
                                               completion: ((Int) -> Void)?) {
        // Payment with a saved card has the same flow as the regular (full) card payment
        internalExecuteCardPayment(token: token,
                                   payload: payload,
                                   fromViewController: fromViewController,
                                   completion: completion)
    }
    
    /// Execute ApplePay payment
    /// - Parameters:
    ///   - paymentIntent: Payment intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
    ///   - payload: Apple Pay configuration
    ///   - fromViewController: Controller to present ApplePay UI over
    ///   - completion: Result of the payment.
    public static func executeApplePayPayment(paymentIntent: DojoPaymentIntent,
                                              payload: DojoApplePayPayload,
                                              fromViewController: UIViewController,
                                              completion: ((Int) -> Void)?) {
        ApplePayHandler.shared.handleApplePay(paymentIntent: paymentIntent,
                                              payload: payload,
                                              fromViewController: fromViewController,
                                              completion: { result in
            completion?(result)
        })
    }
    
    /// Check if apple pay is available for this device
    /// - Parameter config: Apple Pay configuration
    /// - Returns: Availability of ApplePay for a particular device
    public static func isApplePayAvailable(config: DojoApplePayConfig) -> Bool {
        ApplePayHandler.shared.canMakeApplePayPayment(config: config)
    }
    
    /// Fetch a payment intent
    /// - Parameters:
    ///   - intentId: ID of payment Intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
    ///   - completion: Payment Intent in String (JSON) format or error
    public static func fetchPaymentIntent(intentId: String,
                                          completion: ((String?, Error?) -> Void)?) {
        handlePaymentIntentFetching(intentId: intentId, completion: completion)
    }
    
    /// Refresh a payment intent
    /// - Parameters:
    ///   - intentId: Id of payment Intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
    ///   - completion: Payment Intent in String (JSON) format or error
    public static func refreshPaymentIntent(intentId: String,
                                            completion: ((String?, Error?) -> Void)?) {
        handlePaymentIntentRefresh(intentId: intentId, completion: completion)
    }
    
    /// Fetch customer's saved payment methods
    /// - Parameters:
    ///   - customerId: Id of the customer
    ///   - customerSecret: Access key for the customer
    ///   - completion: Customer's saved payment methods in String (JSON) format or error
    public static func fetchCustomerPaymentMethods(customerId: String,
                                                   customerSecret: String,
                                                   completion: ((String?, Error?) -> Void)?) {
        handleFetchCustomerPaymentMethods(customerId: customerId, customerSecret: customerSecret, completion: completion)
    }
    
    /// Delete a customer's saved payment method
    /// - Parameters:
    ///   - customerId: Id of the customer
    ///   - paymentMethodId: Id of the payment method to delete
    ///   - customerSecret: Access key for the customer
    ///   - completion:
    public static func deleteCustomerPaymentMethod(customerId: String,
                                                   paymentMethodId: String,
                                                   customerSecret: String,
                                                   completion: ((Error?) -> Void)?) {
        handleDeleteCustomerPaymentMethod(customerId: customerId, paymentMethodId: paymentMethodId, customerSecret: customerSecret, completion: completion)
    }
}

private extension DojoSDK {
    static func sendCompletionOnMainThread(result: Int, completion: ((Int) -> Void)?) {
        DispatchQueue.main.async {
            completion?(result)
        }
    }
    
    private static func internalExecuteCardPayment(token: String,
                                                   payload: DojoCardPaymentPayloadProtocol,
                                                   fromViewController: UIViewController,
                                                   completion: ((Int) -> Void)?) {
        let networkService = NetworkService(timeout: 25)
        let threeDSCheck = CardinaMobile()
        networkService.collectDeviceData(token: token, payload: payload) { result in
            switch result {
            case .deviceDataRequired(let formToken):
                threeDSCheck.startSession(jwt: formToken, completion: { error in
                    if let _ = error {
                        sendCompletionOnMainThread(result: DojoSDKResponseCode.sdkInternalError.rawValue, completion: completion)
                        return
                    }
                    networkService.performCardPayment(token: token, payload: payload) { cardPaymentResult in
                        switch cardPaymentResult {
                        case .threeDSRequired(let paReq, let md):
                            threeDSCheck.performThreeDScheck(transactionId: md, payload: paReq) { threeDSResultPayload in
                                networkService.submitThreeDSecurePayload(token: token, paRes: threeDSResultPayload, transactionId: md) { paymentResult in
                                    switch paymentResult {
                                    case .result(let resultCode):
                                        sendCompletionOnMainThread(result: resultCode, completion: completion)
                                    default:
                                        sendCompletionOnMainThread(result: DojoSDKResponseCode.sdkInternalError.rawValue, completion: completion)
                                    }
                                }
                            }
                        case .result(let resultCode):
                            sendCompletionOnMainThread(result: resultCode, completion: completion)
                        default:
                            sendCompletionOnMainThread(result: DojoSDKResponseCode.sdkInternalError.rawValue, completion: completion)
                        }
                    }
                })
            case .result(let resultCode):
                sendCompletionOnMainThread(result: resultCode, completion: completion)
            default:
                sendCompletionOnMainThread(result: DojoSDKResponseCode.sdkInternalError.rawValue, completion: completion)
            }
        }
    }
}
