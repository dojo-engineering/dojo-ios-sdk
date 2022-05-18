//
//  DojoApplePayPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

@objc
public class DojoApplePayPayload: NSObject {
    @objc public init(applePayConfig: DojoApplePayConfig,
                      email: String? = nil,
                      metaData: [String : String]? = nil,
                      isSandbox: Bool = false) {
        self.applePayConfig = applePayConfig
        self.email = email
        self.metaData = metaData
        self.isSandbox = isSandbox
    }
    
    let applePayConfig: DojoApplePayConfig
    let email: String?
    let metaData: [String: String]?
    let isSandbox: Bool
}

