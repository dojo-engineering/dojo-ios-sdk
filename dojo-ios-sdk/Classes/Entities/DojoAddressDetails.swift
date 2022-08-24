//
//  DojoAddressDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation
    /// Object that is used for billing address and is a part of shipping address
@objc public class DojoAddressDetails: NSObject, Codable {
    /// Creates an instance of DojoAddressDetails
    /// - Parameters:
    ///   - address1: Address line 1 (for example, company name).
    ///   - address2: Address line 2 (for example, street, apartment, or suite).
    ///   - address3: Address line 3.
    ///   - address4: Address line 4.
    ///   - city: City, town, district, suburb, or village.
    ///   - state: State, province, or region.
    ///   - postcode: ZIP or postal code.
    ///   - countryCode: Two-letter country code in [ISO 3166–1-alpha-2 format](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    @objc public init(address1: String? = nil,
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
    
    /// Address line 1 (for example, company name).
    public let address1: String?
    /// Address line 2 (for example, street, apartment, or suite).
    public let address2: String?
    /// Address line 3.
    public let address3: String?
    /// Address line 4.
    public let address4: String?
    /// City, town, district, suburb, or village.
    public let city: String?
    /// State, province, or region.
    public let state: String?
    /// ZIP or postal code.
    public let postcode: String?
    /// Two-letter country code in [ISO 3166–1-alpha-2 format](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    public let countryCode: String?
}
