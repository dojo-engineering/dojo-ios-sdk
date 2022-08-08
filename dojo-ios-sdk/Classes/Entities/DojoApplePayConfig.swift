//
//  DojoApplePayConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation
/// Object that holds ApplePay configuration
@objc public class DojoApplePayConfig: NSObject {
    /// Creates an instance of DojoApplePayConfig
    /// - Parameters:
    ///   - merchantIdentifier: Merchant identifier that is registered in developer portal
    ///   - collectBillingAddress: Flag that determines collection of billing address from the ApplePay
    ///   - collectShippingAddress: Flag that determines collection of shipping address from the ApplePay
    ///   - collectEmail: Flag that determines collection of email from the ApplePay
    @objc public init(merchantIdentifier: String,
                      collectBillingAddress: Bool = false,
                      collectShippingAddress: Bool = false,
                      collectEmail: Bool = false) {
        self.merchantIdentifier = merchantIdentifier
        self.collectBillingAddress = collectBillingAddress
        self.collectShippingAddress = collectShippingAddress
        self.collectEmail = collectEmail
    }
    
    /// Merchant identifier that is registered in developer portal
    public let merchantIdentifier: String
    /// Flag that determines collection of billing address from the ApplePay
    public let collectBillingAddress: Bool
    /// Flag that determines collection of shipping address from the ApplePay
    public let collectShippingAddress: Bool
    /// Flag that determines collection of email from the ApplePay
    public let collectEmail: Bool
    
}
