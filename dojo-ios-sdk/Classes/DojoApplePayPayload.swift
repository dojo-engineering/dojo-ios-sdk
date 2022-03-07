//
//  DojoApplePayPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

public struct DojoApplePayPayload {
    public init(applePayConfig: DojoApplePayConfig,
                email: String? = nil,
                metaData: [String : String]? = nil) {
        self.applePayConfig = applePayConfig
        self.email = email
        self.metaData = metaData
    }
    
    let applePayConfig: DojoApplePayConfig
    let email: String?
    let metaData: [String: String]?
}

