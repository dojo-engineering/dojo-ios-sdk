//
//  ViewController.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 03/06/2022.
//  Copyright (c) 2022 Deniss Kaibagarovs. All rights reserved.
//

import UIKit
import dojo_ios_sdk

class ViewController: UIViewController {

    @IBAction func onStartCardPaymentPress(_ sender: Any) {
        print("startCardPayment")
        
        let cardDetails = DojoCardDetails(cardNumber: "4456530000001096", cardName: "Card holder", expiryDate: "12 / 24", cv2: "020")
        let cardPaymentPayload = DojoCardPaymentPayload(cardDetails: cardDetails)
        
        showLoadingIndicator()
        DojoSDK.executeCardPayment(token: "1KJi8PLAowjsB8Kw4zr4QE07-vpsVBHedzZjPmlZ3sPiMDYm5p0N6TAw9msRiZlZkVj418Pa2IEHMDqdRs4OUu5SL4IRTtr3SslFr5xunxGEiWLtqbpBfoR7wQHiZJj4gyn8g8NRtmcRHj1cZA==",
                                 payload: cardPaymentPayload,
                                 fromViewController: self) { [weak self] result in
            self?.hideLoadingIndicator()
            self?.showAlert(result)
        }
    }
    
    @IBAction func onApplePayPaymentPress(_ sender: Any) {
        print("startApplePay")
        
        let applePayConfig = DojoApplePayConfig(merchantIdentifier:"merchant.dojo.com")
        let applePayPayload = DojoApplePayPayload(applePayConfig: applePayConfig)
        
        DojoSDK.executeApplePayPayment(token: "token", payload: applePayPayload, fromViewController: self) { [weak self] result in
            print("finished with result:")
            self?.showAlert(result)
        }
    }
    
    private func showAlert(_ error: NSError?) {
        var title = ""
        if let error = error {
            switch error.code {
            case 0:
                title = "Cancel"
            default:
                title = "Other Error"
            }
        } else {
            title = "Success"
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showLoadingIndicator() {
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.tag = 1984
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            if let loadingView = self.view.subviews.first(where: {$0.tag  == 1984}) {
                loadingView.removeFromSuperview()
            }
        }
    }
}

