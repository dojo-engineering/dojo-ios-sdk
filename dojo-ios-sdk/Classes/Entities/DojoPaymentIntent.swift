//
//  DojoPaymentIntent.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 01/05/2022.
//

import Foundation
/// Payment intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
@objc public class DojoPaymentIntent: NSObject, Codable {
    /// Creates an instance of DojoPaymentIntent
    /// - Parameters:
    ///   - clientSessionSecret:Payment secret obtained from a paymentIIntent object.
    ///   - totalAmount: Total payment amount obtained from a paymentIIntent object.
    @objc public init(clientSessionSecret: String,
                      totalAmount: DojoPaymentIntentAmount) {
        self.clientSessionSecret = clientSessionSecret
        self.totalAmount = totalAmount
    }
    
    /// Payment secret obtained from a paymentIIntent object
    public let clientSessionSecret: String
    /// Total payment amount obtained from a paymentIIntent object
    public let totalAmount: DojoPaymentIntentAmount
}

/// Amount of payment intent [reference](https://docs.dojo.tech/api#tag/Payment-intents)
@objc public class DojoPaymentIntentAmount: NSObject, Codable {
    
    /// Creates an instance of DojoPaymentIntentAmount
    /// - Parameters:
    ///   - value: The amount in the minor unit, for example "100" for 1.00 GBP.
    ///   - currencyCode: Three-letter currency code in [ISO 4217 alpha-3](https://en.wikipedia.org/wiki/ISO_4217) format.
    @objc public init(value: UInt64,
                      currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }
    
    /// The amount in the minor unit, for example "100" for 1.00 GBP.
    public let value: UInt64
    /// Three-letter currency code in [ISO 4217 alpha-3](https://en.wikipedia.org/wiki/ISO_4217) format.
    public let currencyCode: String
}
