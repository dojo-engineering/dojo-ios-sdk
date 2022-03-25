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
    static func executeApplePayPayment(token: String,
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
            // TODO error if token is exired for data collection
            switch result {
            case .deviceDataRequired(let formAction, let formToken):
                // Collect details
                handleDeviceDataCollection(token: formToken, formAction: formAction ) { res in
                    if let err = res { // error from token
                        DispatchQueue.main.asyncAfter(deadline: .now()) { // TODO
                            completion?(err)
                        }
                        return // don't need to continue
                    }
                    
                    // Perform card payment
                    networkService.performCardPayment(token: token, payload: payload) { cardPaymentResult in
                        switch cardPaymentResult {
                        case .threeDSRequired(let stepUpUrl, let jwt, let md):
                            handle3DSFlow(stepUpUrl: stepUpUrl, jwt: jwt, md: md, fromViewController: fromViewController, completion: completion)
                        case .result(let resultCode):
                            DispatchQueue.main.asyncAfter(deadline: .now()) { // TODO
                                completion?(resultCode)
                            }
                        default:
                            break
                        }
                    }
                }
            case .result(let resultCode):
                DispatchQueue.main.asyncAfter(deadline: .now()) { // TODO
                    completion?(resultCode)
                }
            default:
                DispatchQueue.main.asyncAfter(deadline: .now()) { // TODO
                    completion?(SDKResponseCode.sdkInternalError.rawValue)
                }
            }
        }
    }
    
    public static func executeApplePayPayment(token: String,
                                              payload: DojoApplePayPayload,
                                              fromViewController: UIViewController,
                                              completion: ((Int) -> Void)?) {
//        let applePayDemoController = ApplePayPlaceholderViewController { result in
//            fromViewController.dismiss(animated: true) {
//                completion?(result)
//            }
//        }
//        if #available(iOS 13.0, *) {
//            applePayDemoController.isModalInPresentation = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            fromViewController.present(applePayDemoController, animated: true, completion: nil)
//        }
    }
}
