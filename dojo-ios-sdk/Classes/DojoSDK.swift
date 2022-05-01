//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

@objc
public protocol DojoSDKProtocol {
    static func executeCardPayment(token: String,
                                   payload: DojoCardPaymentPayload,
                                   fromViewController: UIViewController,
                                   completion: ((Int) -> Void)?)
    static func executeApplePayPayment(paymentIntent: DojoPaymentIntent,
                                       payload: DojoApplePayPayload,
                                       fromViewController: UIViewController,
                                       completion: ((Int) -> Void)?)
}

@objc
public class DojoSDK: NSObject, DojoSDKProtocol {
    public static func executeCardPayment(token: String,
                                          payload: DojoCardPaymentPayload,
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
}

private extension DojoSDK {
    static func sendCompletionOnMainThread(result: Int, completion: ((Int) -> Void)?) {
        DispatchQueue.main.async {
            completion?(result)
        }
    }
}
