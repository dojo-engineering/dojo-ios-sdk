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
                      userEmailAddress: String? = nil,
                      userPhoneNumber: String? = nil,
                      billingAddress: DojoAddressDetails? = nil,
                      shippingDetails: DojoShippingDetails? = nil,
                      metaData: [String : String]? = nil,
                      isSandbox: Bool = false) {
        self.cardDetails = cardDetails
        self.userEmailAddress = userEmailAddress
        self.userPhoneNumber = userPhoneNumber
        self.billingAddress = billingAddress
        self.shippingDetails = shippingDetails
        self.metaData = metaData
        self.isSandbox = isSandbox
    }
    
    let cardDetails: DojoCardDetails
    let userEmailAddress: String?
    let userPhoneNumber: String?
    let billingAddress: DojoAddressDetails?
    let shippingDetails: DojoShippingDetails?
    let metaData: [String: String]?
    let isSandbox: Bool
}


