//
//  DojoCardDetails.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

public struct DojoCardDetails {
    public init(cardNumber: String,
                cardName: String? = nil,
                expiryDate: String? = nil,
                cv2: String? = nil) {
        self.cardNumber = cardNumber
        self.cardName = cardName
        self.expiryDate = expiryDate
        self.cv2 = cv2
    }
    
    let cardNumber: String
    let cardName: String?
    let expiryDate: String?
    let cv2: String?
}
