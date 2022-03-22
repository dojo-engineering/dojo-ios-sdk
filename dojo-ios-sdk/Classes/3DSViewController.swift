//
//  3DSView.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit
import WebKit

class ThreeDSViewController: UIViewController, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        print("message: \(message.body)")
        completion?(true)
    }
    
    
    private var webView: WKWebView?
    private var completion: ((Bool) -> Void)?
    private var acsUrl: String?
    private var md: String?
    private var jwt: String?
    private var paReq: String?
    private var timeoutTimer: Timer?
    private var timeoutTimerTime = 15.0
    
    convenience init(acsUrl: String?, md: String?, jwt: String?, paReq: String?, completion: ((Bool) -> Void)?) {
        self.init()
        self.acsUrl = acsUrl
        self.md = md
        self.jwt = jwt
        self.paReq = paReq
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        let source = "window.addEventListener('message', (event) => { window.webkit.messageHandlers.iosListener.postMessage('click clack!');})"
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
        <body>
        <form id="threeDs20Form" target="_self" method="post" action="\(acsUrl!)">
            <input type="hidden" name="PaReq" value="\(paReq!)">
            <input name="JWT" value="\(jwt!)"/>
            <input name="MD" value="\(md!)"/>
            <input name="TermUrl" value="https://www.test.paysafe.com/cgi-bin/echo"/>
        </form>
        </div>
        </body>
        </html>
        """
    }
}

extension ThreeDSViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        var a = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webView.url?.absoluteString)
        webView.evaluateJavaScript("document.getElementById('threeDs20Form').submit()", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url?.absoluteString)
//        if let result = webView.url?.absoluteString.contains("success"),
//           result {
//            completion?(true)
//        }
//
//        if let result = webView.url?.absoluteString.contains("fail"),
//           result {
//            completion?(false)
//        }
    }

}


