//
//  DojoSavedCardPaymentPayload.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 28/07/2022.
//
import Foundation
/// Object that holds DojoSavedCardPaymentPayload configuration
@objc public class DojoSavedCardPaymentPayload: NSObject, DojoCardPaymentPayloadProtocol {
    /// Creates an instance of DojoSavedCardPaymentPayload
    /// - Parameters:
    ///   - cvv: CVV, CVC or CVC2 of a card.
    ///   - paymentMethodId: Id of the saved card.
    ///   - userEmailAddress: The customer's email address.
    ///   - userPhoneNumber: The customer's phone number.
    ///   - shippingDetails: The address where to send the order.
    ///   - metaData: A set of key-value pairs that you can use for storing additional information.
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
    
    /// CVV, CVC or CVC2 of a card.
    public let cV2: String
    /// Id of the saved card.
    public let paymentMethodId: String
    /// The customer's email address.
    public let userEmailAddress: String?
    /// The customer's phone number.
    public let userPhoneNumber: String?
    /// The address where to send the order.
    public let shippingDetails: DojoShippingDetails?
    /// A set of key-value pairs that you can use for storing additional information.
    public let metaData: [String: String]?
    /// Set if you want to run your payment over Staging
    public let isSandbox: Bool
    
    func getRequestBody() -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: self)) else {
            return nil
        }
        return bodyData
    }
}
