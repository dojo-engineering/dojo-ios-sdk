//
//  NetworkService.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

struct CardPaymentDataRequest: Encodable {
    let cV2: String?
    let paymentMethodId: String?
    let cardName: String?
    let cardNumber: String?
    let expiryDate: String?
    let mitConsentGiven: Bool?
    
    let userEmailAddress: String?
    let userPhoneNumber: String?
    let billingAddress: DojoAddressDetails?
    let shippingDetails: DojoShippingDetails?
    let metaData: [String : String]?
    let savePaymentMethod: Bool?
    
    init(payload: DojoCardPaymentPayload) {
        self.cV2 = payload.cardDetails.cv2
        self.cardName = payload.cardDetails.cardName
        self.cardNumber = payload.cardDetails.cardNumber
        self.expiryDate = payload.cardDetails.expiryDate
        self.mitConsentGiven = payload.cardDetails.mitConsentGiven
        self.userEmailAddress = payload.userEmailAddress
        self.userPhoneNumber = payload.userPhoneNumber
        self.billingAddress = payload.billingAddress
        self.shippingDetails = payload.shippingDetails
        self.metaData = payload.metaData
        self.savePaymentMethod = payload.savePaymentMethod
        
        self.paymentMethodId = nil
    }
    
    init(payload: DojoSavedCardPaymentPayload) {
        self.cV2 = payload.cV2
        self.paymentMethodId = payload.paymentMethodId
        self.userEmailAddress = payload.userEmailAddress
        self.userPhoneNumber = payload.userPhoneNumber
        self.shippingDetails = payload.shippingDetails
        self.metaData = payload.metaData
        
        self.cardName = nil
        self.cardNumber = nil
        self.expiryDate = nil
        self.billingAddress = nil
        self.savePaymentMethod = nil
        self.mitConsentGiven = nil
    }
}
