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
                                   completion: ((NSError?) -> Void)?)
    static func executeApplePayPayment(token: String,
                                       payload: DojoApplePayPayload,
                                       fromViewController: UIViewController,
                                       completion: ((NSError?) -> Void)?)
}

@objc
public class DojoSDK: NSObject, DojoSDKProtocol {
    public static func executeCardPayment(token: String,
                                          payload: DojoCardPaymentPayload,
                                          fromViewController: UIViewController,
                                          completion: ((NSError?) -> Void)?) {
        let networkService = NetworkService(timeout: 25)
        networkService.collectDeviceData(token: token, payload: payload) { result in
            // TODO error if token is exired for data collection
            
            // Collect details
            handleDeviceDataCollection(token: result?.token) { res in
                if let err = res { // error from token
                    DispatchQueue.main.asyncAfter(deadline: .now()) { // TODO
                        completion?(err)
                    }
                    return // don't need to continue
                }
                
                // Perform card payment
                networkService.performCardPayment(token: token, payload: payload) { cardPaymentResult in
                    switch cardPaymentResult {
                    case .ThreeDSRequired(let stepUpUrl, let jwt, let md):
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            let threeDSController = ThreeDSViewController(stepUpUrl: stepUpUrl, md: md, jwt: jwt) { threeDS in
                                fromViewController.dismiss(animated: true, completion: {
                                    completion?(nil)
                                })
                            }
                            fromViewController.present(threeDSController, animated: false, completion: nil)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    public static func executeApplePayPayment(token: String,
                                              payload: DojoApplePayPayload,
                                              fromViewController: UIViewController,
                                              completion: ((NSError?) -> Void)?) {
        let applePayDemoController = ApplePayPlaceholderViewController { result in
            fromViewController.dismiss(animated: true) {
                completion?(result)
            }
        }
        if #available(iOS 13.0, *) {
            applePayDemoController.isModalInPresentation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            fromViewController.present(applePayDemoController, animated: true, completion: nil)
        }
    }
}
