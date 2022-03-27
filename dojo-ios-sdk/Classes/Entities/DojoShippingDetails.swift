//
//  DojoShippingDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

@objc
public class DojoShippingDetails: NSObject, Codable {
    @objc public init(name: String? = nil,
                  address: DojoAddressDetails? = nil) {
        self.name = name
        self.address = address
    }
    
    let name: String?
    let address: DojoAddressDetails?
}
