//
//  DojoSDKDebugConfig.swift
//  dojo-ios-sdk
//
//

import Foundation
    
@objc public class DojoSDKDebugConfig: NSObject {
    
    public let urlConfig: DojoSDKURLConfig?
    public let isSandboxIntent: Bool
    public let isSandboxWallet: Bool
    
 
    @objc public init(urlConfig: DojoSDKURLConfig? = nil,
                      isSandboxIntent: Bool = false,
                      isSandboxWallet: Bool = false) {
        self.urlConfig = urlConfig
        self.isSandboxIntent = isSandboxIntent
        self.isSandboxWallet = isSandboxWallet
    }
    
}

@objc public class  DojoSDKURLConfig: NSObject {
    public let connecte: String?
    public let remote: String?
    
    @objc public init(connecte: String? = nil,
                      remote: String? = nil) {
        self.connecte = connecte
        self.remote = remote
    }
}
