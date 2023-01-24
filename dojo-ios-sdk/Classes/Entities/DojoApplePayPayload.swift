//
//  DojoApplePayPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation
///Object that holds DojoSDK ApplePay configuration
@objc public class DojoApplePayPayload: NSObject {
    /// Creates an instance of DojoApplePayPayload
    /// - Parameters:
    ///   - applePayConfig: ApplePay related settings.
    ///   - userEmailAddress: The customer's email address.
    ///   - metaData: A set of key-value pairs that you can use for storing additional information.
    @objc public init(applePayConfig: DojoApplePayConfig,
                      userEmailAddress: String? = nil,
                      metaData: [String : String]? = nil) {
        self.applePayConfig = applePayConfig
        self.userEmailAddress = userEmailAddress
        self.metaData = metaData
    }
    
    /// ApplePay related settings.
    public let applePayConfig: DojoApplePayConfig
    /// The customer's email address.
    public let userEmailAddress: String?
    /// A set of key-value pairs that you can use for storing additional information.
    public let metaData: [String: String]?
}

