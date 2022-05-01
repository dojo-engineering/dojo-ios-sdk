//
//  ApplePayDataRequest.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 01/05/2022.
//

import Foundation

struct ApplePayDataRequest: Codable {
    let token: ApplePayDataToken
}

struct ApplePayDataToken: Codable {
    let paymentData: ApplePayDataTokenPaymentData
    let paymentMethod: ApplePayDataTokenPaymentMethod
    let transactionIdentifier: String
}

struct ApplePayDataTokenPaymentData: Codable {
    let data: String
    let signature: String
    let header: ApplePayDataTokenPaymentDataHeaders
    let version: String
}

struct ApplePayDataTokenPaymentMethod: Codable {
    let displayName: String
    let network: String
    let type: String
}

struct ApplePayDataTokenPaymentDataHeaders: Codable {
    let publicKeyHash: String
    let ephemeralPublicKey: String
    let transactionId: String
}
