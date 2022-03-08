//
//  DojoAddressDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

@objc
public class DojoAddressDetails: NSObject {
    public init(address1: String? = nil,
                  address2: String? = nil,
                  address3: String? = nil,
                  address4: String? = nil,
                  city: String? = nil,
                  state: String? = nil,
                  postcode: String? = nil,
                  countryCode: String? = nil) {
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.address4 = address4
        self.city = city
        self.state = state
        self.postcode = postcode
        self.countryCode = countryCode
    }
    
    let address1: String?
    let address2: String?
    let address3: String?
    let address4: String?
    let city: String?
    let state: String?
    let postcode: String?
    let countryCode: String?
}
