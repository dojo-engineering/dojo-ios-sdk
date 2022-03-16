//
//  DojoConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import Foundation

@objc
public class DojoCardPaymentPayload: NSObject, Codable {
    @objc public init(cardDetails: DojoCardDetails,
                  email: String? = nil,
                  billingAddress: DojoAddressDetails? = nil,
                  shippingDetails: DojoShippingDetails? = nil,
                  metaData: [String : String]? = nil) {
        self.cardDetails = cardDetails
        self.email = email
        self.billingAddress = billingAddress
        self.shippingDetails = shippingDetails
        self.metaData = metaData
    }
    
    let cardDetails: DojoCardDetails
    let email: String?
    let billingAddress: DojoAddressDetails?
    let shippingDetails: DojoShippingDetails?
    let metaData: [String: String]?
}


