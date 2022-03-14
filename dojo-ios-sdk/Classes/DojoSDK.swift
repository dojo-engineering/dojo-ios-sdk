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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let threeDSController = ThreeDSViewController() { is3DSSuccess in
                fromViewController.dismiss(animated: true) {
                    if is3DSSuccess {
                        completion?(nil)
                    } else {
                        completion?(ErrorBuilder.serverError(.threeDSError))
                    }
                }
            }
            if #available(iOS 13.0, *) {
                threeDSController.isModalInPresentation = true
            }
            fromViewController.present(threeDSController, animated: true, completion: nil)
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
