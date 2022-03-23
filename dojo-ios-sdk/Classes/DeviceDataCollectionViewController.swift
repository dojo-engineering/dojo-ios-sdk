//
//  3DSView.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit
import WebKit

class DeviceDataCollectionViewController: UIViewController, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard !didReceiveMessage else {
            return
        }
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        print("message: \(message.body)")
        didReceiveMessage = true
        completion?(true)
    }
    
    
    private var webView: WKWebView?
    private var completion: ((Bool) -> Void)?
    private var token: String?
    private var timeoutTimer: Timer?
    private var timeoutTimerTime = 15.0
    private var didReceiveMessage = false
    
    convenience init(token: String?, completion: ((Bool) -> Void)?) {
        self.init()
        self.token = token
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutTimerTime, repeats: false) { [weak self] timer in
            self?.completion?(true) //TODO make more robubst
        }
        
        let config = WKWebViewConfiguration()
        let source = "window.addEventListener('message', (event) => {if (event.origin !== 'https://centinelapistag.cardinalcommerce.com') { return; } window.webkit.messageHandlers.iosListener.postMessage('click clack!');})"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
            config.userContentController.add(self, name: "iosListener")
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        
     
        
        webView.loadHTMLString(getDemoPage(), baseURL:nil)
        self.view.addSubview(webView)
        
        self.webView = webView
    }
    
    func getDemoPage() -> String { // TODO force unwrap
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

        <iframe name=”ddc-iframe” height="1" width="1"> </iframe>
        <form id="ddc-form" target=”ddc-iframe”  method="POST" action="https://centinelapistag.cardinalcommerce.com/V1/Cruise/Collect">
            <input id="ddc-input" name="JWT" value="\(token!)" />
        </form>
        </body>
        </html>

        """
    }
}

extension DeviceDataCollectionViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        var a = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var a = 0
        webView.evaluateJavaScript("document.getElementById('ddc-form').submit()", completionHandler: nil)
    }
    
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


