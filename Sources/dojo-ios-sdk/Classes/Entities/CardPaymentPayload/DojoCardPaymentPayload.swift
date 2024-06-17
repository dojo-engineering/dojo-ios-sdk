//
//  DojoConfig.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import Foundation
/// Object that holds CardPayment configuration and data
@objc public class DojoCardPaymentPayload: NSObject, DojoCardPaymentPayloadProtocol {
    /// Creates an instance of DojoCardPaymentPayload
    /// - Parameters:
    ///   - cardDetails: Card details of a card that is used for chek out
    ///   - userEmailAddress: The customer's email address.
    ///   - userPhoneNumber: The customer's phone number.
    ///   - billingAddress: The address where to send the invoice.
    ///   - shippingDetails: The address where to send the order.
    ///   - metaData: A set of key-value pairs that you can use for storing additional information.
    @objc public init(cardDetails: DojoCardDetails,
                      userEmailAddress: String? = nil,
                      userPhoneNumber: String? = nil,
                      billingAddress: DojoAddressDetails? = nil,
                      shippingDetails: DojoShippingDetails? = nil,
                      metaData: [String : String]? = nil,
                      savePaymentMethod: Bool = false) {
        self.cardDetails = cardDetails
        self.userEmailAddress = userEmailAddress
        self.userPhoneNumber = userPhoneNumber
        self.billingAddress = billingAddress
        self.shippingDetails = shippingDetails
        self.metaData = metaData == nil ? [:] : metaData
        self.savePaymentMethod = savePaymentMethod
    }
    
    /// Card details of a card that is used for chek out
    public let cardDetails: DojoCardDetails
    /// The customer's email address.
    public let userEmailAddress: String?
    /// The customer's phone number.
    public let userPhoneNumber: String?
    /// The address where to send the invoice.
    public let billingAddress: DojoAddressDetails?
    /// The address where to send the order.
    public let shippingDetails: DojoShippingDetails?
    /// A set of key-value pairs that you can use for storing additional information.
    public var metaData: [String: String]?
    /// Set if you want to save this payment method on user's account
    public let savePaymentMethod: Bool
}

extension DojoCardPaymentPayload {
    func getRequestBody() -> Data? {
        let encoder = JSONEncoder()
        self.metaData?[getMetadataSDKVersionKey()] = getMetadataSDKVersion()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: self)) else {
            return nil
        }
        return bodyData
    }
}

