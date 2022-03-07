//
//  3DSView.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit
import WebKit

class ThreeDSViewController: UIViewController {
    
    private var webView: WKWebView?
    private var completion: ((Bool) -> Void)?
    
    convenience init(completion: ((Bool) -> Void)?) {
        self.init()
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        webView.loadHTMLString(getDemoPage(), baseURL:nil)
        self.view.addSubview(webView)
        
        self.webView = webView
    }
    
    func getDemoPage() -> String {
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

        <p>This is a demo 3DS page</p>
        <a href="https://www.3ds.com/success">Success</a>
        <a href="https://www.3ds.com/fail">Fail</a>

        </body>
        </html>

        """
    }
}

extension ThreeDSViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) { }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let result = webView.url?.absoluteString.contains("success"),
           result {
            completion?(true)
        }
        
        if let result = webView.url?.absoluteString.contains("fail"),
           result {
            completion?(false)
        }
    }
}


