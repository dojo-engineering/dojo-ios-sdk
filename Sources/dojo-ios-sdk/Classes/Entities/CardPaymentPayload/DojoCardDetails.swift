//
//  DojoCardDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation
/// Object that holds card details
@objc public class DojoCardDetails: NSObject, Codable {
    /// Creates an instance of DojoCardDetails
    /// - Parameters:
    ///   - cardNumber: PAN (Primary Account Number) of a card
    ///   - cardName: Card holder name from a card
    ///   - expiryDate: Expiry date of a card in format "MM / YY"
    ///   - cv2: CVV, CVC or CVC2 of a card
    @objc public init(cardNumber: String,
                      cardName: String? = nil,
                      expiryDate: String? = nil,
                      cv2: String? = nil) {
        self.cardNumber = cardNumber
        self.cardName = cardName
        self.expiryDate = expiryDate
        self.cv2 = cv2
    }
    
    /// PAN (Primary Account Number) of a card
    public let cardNumber: String
    /// Card holder name from a card
    public let cardName: String?
    /// Expiry date of a card in format "MM / YY"
    public let expiryDate: String?
    /// CVV, CVC or CVC2 of a card
    public let cv2: String?
}
