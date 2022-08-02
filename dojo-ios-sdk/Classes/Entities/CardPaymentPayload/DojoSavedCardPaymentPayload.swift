//
//  DojoSavedCardPaymentPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 28/07/2022.
//
import Foundation

@objc
public class DojoSavedCardPaymentPayload: NSObject, DojoCardPaymentPayloadProtocol {
    
    @objc public init(cvv: String,
                      paymentMethodId: String,
                      isSandbox: Bool = false) {
        self.cV2 = cvv
        self.paymentMethodId = paymentMethodId
        self.isSandbox = isSandbox
    }
    
    let cV2: String
    let paymentMethodId: String
    var isSandbox: Bool
    
    func getRequestBody() -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: self)) else {
            return nil
        }
        return bodyData
    }
}
