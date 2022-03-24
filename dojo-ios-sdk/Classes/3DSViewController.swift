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
//        print(message.body) TODO - proper logs
        if let dict = message.body as? Dictionary<String, Any> {
            if let mesData = dict["messageData"] as? Dictionary<String, Any> {
                print("transaction result: \(mesData["statusCode"])")
                timeoutTimer?.invalidate()
                timeoutTimer = nil
                completion?(true)
            }
        }
    }
    
    private var webView: WKWebView?
    private var completion: ((Bool) -> Void)?
    private var stepUpUrl: String = ""
    private var md: String = ""
    private var jwt: String = ""
    private var timeoutTimer: Timer?
    private var timeoutTimerTime = 15.0
    
    convenience init(stepUpUrl: String, md: String, jwt: String, completion: ((Bool) -> Void)?) {
        self.init()
        self.stepUpUrl = stepUpUrl
        self.md = md
        self.jwt = jwt
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        let source = "window.addEventListener('message', (event) => { window.webkit.messageHandlers.iosListener.postMessage(event.data);})"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
            config.userContentController.add(self, name: "iosListener")
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        
        webView.loadHTMLString(getHTMLContent(stepUpUrl: stepUpUrl, jwt: jwt, md: md), baseURL:nil)
        self.view.addSubview(webView)
        self.webView = webView
    }
    
    func getHTMLContent(stepUpUrl: String, jwt: String, md: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <body>
        <form id="threeDs20Form" target="_self" method="post" action="\(stepUpUrl)">
            <input name="JWT" value="\(jwt)"/>
            <input name="MD" value="\(md)"/>
        </form>
        </div>
        </body>
        </html>
        """
    }
}

extension ThreeDSViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementById('threeDs20Form').submit()", completionHandler: nil)
    }
}


