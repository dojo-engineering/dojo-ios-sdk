//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit
import WebKit

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
            // TODO error if token is exired
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                let controller = DeviceDataCollectionViewController(token: result?.token) { res in
                    //                    completion?(nil)
                    fromViewController.dismiss(animated: true, completion: {
                        networkService.performCardPayment(token: token, payload: payload) { carPayment in
                            switch carPayment {
                            case .ThreeDSRequired(let ascUrl, let jwt, let md, let paReq):
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    let threeDSController = ThreeDSViewController(acsUrl: ascUrl, md: md, jwt: jwt, paReq: paReq) { threeDS in
                                        fromViewController.dismiss(animated: true, completion: {
                                            completion?(nil)
                                        })
                                    }
                                    fromViewController.present(threeDSController, animated: true, completion: nil)
                                }
                                break
                            default:
                                break
                            }
                            var a = 0
                        }
                    })
                    
                }
                fromViewController.present(controller, animated: true, completion: nil)
                //                controller.viewDidLoad()
                //                controller.viewDidAppear(true)
                //                controller.didMove(toParentViewController: fromViewController)
            }
        }
        
        //        NetworkService(timeout: 25).performCardPayment(token: token, payload: payload) { response in
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // TODO
        //                switch response {
        //                case .error(let error):
        //                    completion?(error)
        //                case .ThreeDSRequired: // change to lower case
        //                    let threeDSController = ThreeDSViewController() { is3DSSuccess in
        //                        fromViewController.dismiss(animated: true) {
        //                            if is3DSSuccess {
        //                                completion?(nil)
        //                            } else {
        //                                completion?(ErrorBuilder.serverError(.threeDSError))
        //                            }
        //                        }
        //                    }
        //                    if #available(iOS 13.0, *) {
        //                        threeDSController.isModalInPresentation = true
        //                    }
        //                    fromViewController.present(threeDSController, animated: true, completion: nil)
        //                case .complete:
        //                    break
        //                }
        //            }
        //        }
    }
    
    static func getDemoPage(token: String?) -> String {
        """
        <!DOCTYPE html>
        <html>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
        <style>
        body {
          background-color: linen;
        }
        
        a {
          margin-right: 40px;
        }
        </style>
        <body>
        <iframe name=”ddc-iframe” height="1" width="1" style="display: none;">
        <form id="ddc-form" target=”ddc-iframe”  method="POST" action="https://centinelapistag.cardinalcommerce.com/V1/Cruise/Collect">
            <input id="ddc-input" type="hidden" name="JWT" value="\(token)" />
        </form>
        </iframe>
        </body>
        </html>
        
        """
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


class DojoSDKWKNavigation: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) { }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var a = 0
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let result = webView.url?.absoluteString.contains("success"),
           result {
            
        }
        
        if let result = webView.url?.absoluteString.contains("fail"),
           result {
            
        }
    }
}
