//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

public protocol DojoSDKProtocol {
    static func executeCardPayment(token: String,
                                   payload: DojoCardPaymentPayload,
                                   fromViewController: UIViewController,
                                   completion: ((DojoSDKResult) -> Void)?)
    static func executeApplePayPayment(token: String,
                                       payload: DojoApplePayPayload,
                                       fromViewController: UIViewController,
                                       completion: ((DojoSDKResult) -> Void)?)
}

public enum DojoSDKResult {
    case success
    case error(DojoSDKError)
}

public enum DojoSDKError: LocalizedError {
    case threeDSFailed
    case applePayFailed
    case canceled
    case other(Error)
    
    public var errorDescription: String? {
            switch self {
            case .threeDSFailed:
                return NSLocalizedString("3DS view failed", comment: "")
            case .applePayFailed:
                return NSLocalizedString("ApplePay failed", comment: "")
            case .canceled:
                return NSLocalizedString("Canceled", comment: "")
            default:
                return nil
            }
        }
}

public class DojoSDK: DojoSDKProtocol {
    
    public static func executeCardPayment(token: String, payload: DojoCardPaymentPayload, fromViewController: UIViewController, completion: ((DojoSDKResult) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let threeDSController = ThreeDSViewController() { is3DSSuccess in
                fromViewController.dismiss(animated: true) {
                    if is3DSSuccess {
                        completion?(.success)
                    } else {
                        completion?(.error(.threeDSFailed))
                    }
                }
            }
            if #available(iOS 13.0, *) {
                threeDSController.isModalInPresentation = true
            }
            fromViewController.present(threeDSController, animated: true, completion: nil)
        }
    }
    
    public static func executeApplePayPayment(token: String, payload: DojoApplePayPayload, fromViewController: UIViewController, completion: ((DojoSDKResult) -> Void)?) {
        let applePayDemoController = ApplePayPlaceholderViewController { result in
            fromViewController.dismiss(animated: true) {
                completion?(result)
            }
        }
        if #available(iOS 13.0, *) {
            applePayDemoController.isModalInPresentation = true
        }
        fromViewController.present(applePayDemoController, animated: true, completion: nil)
    }
}
