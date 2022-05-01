//
//  DojoApplePayConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

@objc
public class DojoApplePayConfig: NSObject {
    @objc public init(merchantIdentifier: String,
                      collectBillingAddress: Bool = false,
                      collectShippingAddress: Bool = false,
                      collectEmail: Bool = false) {
        self.merchantIdentifier = merchantIdentifier
        self.collectBillingAddress = collectBillingAddress
        self.collectShippingAddress = collectShippingAddress
        self.collectEmail = collectEmail
    }
    
    let merchantIdentifier: String
    let collectBillingAddress: Bool
    let collectShippingAddress: Bool
    let collectEmail: Bool
}
