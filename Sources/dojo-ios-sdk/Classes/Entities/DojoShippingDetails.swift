//
//  DojoShippingDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation
/// The address where to send the order.
@objc public class DojoShippingDetails: NSObject, Codable {
    /// Creates an instance of DojoShippingDetails
    /// - Parameters:
    ///   - name: The name of the customer.
    ///   - address: Details about the address.
    @objc public init(name: String? = nil,
                      address: DojoAddressDetails? = nil) {
        self.name = name
        self.address = address
    }
    
    /// The name of the customer.
    public let name: String?
    /// Details about the address.
    public let address: DojoAddressDetails?
}
