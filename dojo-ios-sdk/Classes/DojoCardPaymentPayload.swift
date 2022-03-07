//
//  DojoConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import Foundation

public struct DojoCardPaymentPayload {
    public init(cardDetails: DojoCardDetails,
                  email: String? = nil,
                  billingAddress: DojoAddressDetails? = nil,
                  shippingDetails: DojoAddressDetails? = nil,
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
    let shippingDetails: DojoAddressDetails?
    let metaData: [String: String]?
}


