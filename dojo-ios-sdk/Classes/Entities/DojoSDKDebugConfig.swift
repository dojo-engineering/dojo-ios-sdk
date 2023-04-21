//
//  DojoSDKDebugConfig.swift
//  dojo-ios-sdk
//
//

import Foundation
    
@objc public class DojoSDKDebugConfig: NSObject {
    
    @objc public let urlConfig: DojoSDKURLConfig?
    @objc public let isSandboxIntent: Bool
    @objc public let isSandboxWallet: Bool
    
 
    @objc public init(urlConfig: DojoSDKURLConfig? = nil,
                      isSandboxIntent: Bool = false,
                      isSandboxWallet: Bool = false) {
        self.urlConfig = urlConfig
        self.isSandboxIntent = isSandboxIntent
        self.isSandboxWallet = isSandboxWallet
    }
    
}

@objc public class  DojoSDKURLConfig: NSObject {
    @objc public let connectE: String?
    @objc public let remote: String?
    
    @objc public init(connectE: String? = nil,
                      remote: String? = nil) {
        self.connectE = connectE
        self.remote = remote
    }
}
