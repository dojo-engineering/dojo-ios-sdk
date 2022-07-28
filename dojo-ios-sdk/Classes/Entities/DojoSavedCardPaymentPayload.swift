//
//  DojoSavedCardPaymentPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 28/07/2022.
//
import Foundation

@objc
public class DojoSavedCardPaymentPayload: NSObject, Codable {
    @objc public init(cvv: String,
                      paymentMethodId: String,
                      isSandbox: Bool = false) {
        self.cV2 = cvv
        self.paymentMethodId = paymentMethodId
        self.isSandbox = isSandbox
    }
    
    let cV2: String //TODO a proper variable for networking request
    let paymentMethodId: String
    let isSandbox: Bool
}
