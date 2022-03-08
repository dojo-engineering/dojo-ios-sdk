//
//  DojoApplePayConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

@objc
public class DojoApplePayConfig: NSObject {
    public init(merchantIdentifier: String,
                collectBillingAddress: Bool? = nil,
                collectShippingAddress: Bool? = nil) {
        self.merchantIdentifier = merchantIdentifier
        self.collectBillingAddress = collectBillingAddress
        self.collectShippingAddress = collectShippingAddress
    }
    
    let merchantIdentifier: String
    let collectBillingAddress: Bool?
    let collectShippingAddress: Bool?
}
