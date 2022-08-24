//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

protocol DojoSDKProtocol {
    static func executeCardPayment(token: String,
                                   payload: DojoCardPaymentPayload,
                                   fromViewController: UIViewController,
                                   completion: ((Int) -> Void)?)
    static func executeSavedCardPayment(token: String,
                                        payload: DojoSavedCardPaymentPayload,
                                        fromViewController: UIViewController,
                                        completion: ((Int) -> Void)?)
    static func executeApplePayPayment(paymentIntent: DojoPaymentIntent,
                                       payload: DojoApplePayPayload,
                                       fromViewController: UIViewController,
                                       completion: ((Int) -> Void)?)
    static func isApplePayAvailable(paymentIntent: DojoPaymentIntent) -> Bool
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
    /// - Parameter paymentIntent: Payment intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
    /// - Returns: Availability of ApplePay for a particular device
    public static func isApplePayAvailable(paymentIntent: DojoPaymentIntent) -> Bool {
        ApplePayHandler.shared.canMakeApplePayPayment()
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
        networkService.collectDeviceData(token: token, payload: payload) { result in
            switch result {
            case .deviceDataRequired(let formAction, let formToken):
                // Collect details
                handleDeviceDataCollection(token: formToken, formAction: formAction ) { res in
                    if let err = res { // error from token
                        sendCompletionOnMainThread(result: err, completion: completion)
                        return // don't need to continue
                    }
                    // Perform card payment
                    networkService.performCardPayment(token: token, payload: payload) { cardPaymentResult in
                        switch cardPaymentResult {
                        case .threeDSRequired(let stepUpUrl, let jwt, let md):
                            handle3DSFlow(stepUpUrl: stepUpUrl, jwt: jwt, md: md, fromViewController: fromViewController) { threeDSResult in
                                sendCompletionOnMainThread(result: threeDSResult, completion: completion)
                            }
                        case .result(let resultCode):
                            sendCompletionOnMainThread(result: resultCode, completion: completion)
                        default:
                            sendCompletionOnMainThread(result: SDKResponseCode.sdkInternalError.rawValue, completion: completion)
                        }
                    }
                }
            case .result(let resultCode):
                sendCompletionOnMainThread(result: resultCode, completion: completion)
            default:
                sendCompletionOnMainThread(result: SDKResponseCode.sdkInternalError.rawValue, completion: completion)
            }
        }
    }
}
