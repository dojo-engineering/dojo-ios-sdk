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
        if let dict = message.body as? Dictionary<String, Any> {
            if let messageData = dict["messageData"] as? Dictionary<String, Any> {
                if let statusCode = messageData["statusCode"] as? Int {
                    completion?(statusCode)
                } else {
                    completion?(SDKResponseCode.sdkInternalError.rawValue)
                }
            }
        }
    }
    
    private var webView: WKWebView?
    private var completion: ((Int) -> Void)?
    private var stepUpUrl: String = ""
    private var md: String = ""
    private var jwt: String = ""
    
    convenience init(stepUpUrl: String, md: String, jwt: String, completion: ((Int) -> Void)?) {
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

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelTapped))
    }
    
    @objc func cancelTapped() {
        completion?(SDKResponseCode.declined.rawValue)
    }
    
    func getHTMLContent(stepUpUrl: String, jwt: String, md: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, shrink-to-fit=YES">
        </head>
        <body>
        <form id="threeDs20Form" target="_self" method="post" action="\(stepUpUrl)">
            <input name="JWT" type="hidden" value="\(jwt)"/>
            <input name="MD" type="hidden" value="\(md)"/>
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
