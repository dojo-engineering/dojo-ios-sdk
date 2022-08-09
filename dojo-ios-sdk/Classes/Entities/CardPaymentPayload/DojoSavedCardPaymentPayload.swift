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
                      userEmailAddress: String? = nil,
                      userPhoneNumber: String? = nil,
                      shippingDetails: DojoShippingDetails? = nil,
                      metaData: [String : String]? = nil,
                      isSandbox: Bool = false) {
        self.cV2 = cvv
        self.paymentMethodId = paymentMethodId
        self.userPhoneNumber = userPhoneNumber
        self.userEmailAddress = userEmailAddress
        self.shippingDetails = shippingDetails
        self.metaData = metaData
        self.isSandbox = isSandbox
    }
    
    let cV2: String
    let paymentMethodId: String
    let userEmailAddress: String?
    let userPhoneNumber: String?
    let shippingDetails: DojoShippingDetails?
    let metaData: [String: String]?
    var isSandbox: Bool
    
    func getRequestBody() -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: self)) else {
            return nil
        }
        return bodyData
    }
}
