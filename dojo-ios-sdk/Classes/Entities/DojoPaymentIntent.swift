//
//  DojoPaymentIntent.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 01/05/2022.
//

import Foundation


// https://docs.dojo.tech/api#operation/PaymentIntents_Get
@objc
public class DojoPaymentIntent: NSObject, Codable {
    @objc public init(connecteToken: String,
                      totalAmount: DojoPaymentIntentAmount) {
        self.connecteToken = connecteToken
        self.totalAmount = totalAmount
    }
    
    let connecteToken: String
    let totalAmount: DojoPaymentIntentAmount
}

@objc
public class DojoPaymentIntentAmount: NSObject, Codable {
    
    @objc public init(value: UInt64,
                      currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }
    
    let value: UInt64
    let currencyCode: String
}
