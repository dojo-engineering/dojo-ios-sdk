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
//        print("message: \(message.body)") TODO logging
        didReceiveMessage = true // TODO
        completion?(true)
    }
    
    
    private var webView: WKWebView?
    private var completion: ((Bool) -> Void)?
    private var token: String = ""
    private var formAction: String = ""
    private var timeoutTimer: Timer?
    private var timeoutTimerTime = 15.0
    private var didReceiveMessage = false
    
    convenience init(token: String, formAction: String, completion: ((Bool) -> Void)?) {
        self.init()
        self.token = token
        self.formAction = formAction
        self.completion = completion
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutTimerTime, repeats: false) { [weak self] timer in
            self?.completion?(true) //TODO make more robubst
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
        
        //TODO the same for both webviews
        let config = WKWebViewConfiguration()
        let source = "window.addEventListener('message', (event) => { window.webkit.messageHandlers.iosListener.postMessage('data collection complete');})"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
            config.userContentController.add(self, name: "iosListener")
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        
        webView.loadHTMLString(getHTMLContent(token: token, formAction: formAction), baseURL:nil)
        self.view.addSubview(webView)
        
        self.webView = webView
    }
    
    func getHTMLContent(token: String, formAction: String) -> String {
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
        <form id="ddc-form" target=”ddc-iframe”  method="POST" action="\(formAction)">
            <input id="ddc-input" name="JWT" value="\(token)" />
        </form>
        </body>
        </html>

        """
    }
}

extension DeviceDataCollectionViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementById('ddc-form').submit()", completionHandler: nil)
    }
}
