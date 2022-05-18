//
//  ApplePayDataRequest.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 01/05/2022.
//

import Foundation

struct ApplePayDataRequest: Codable {
    let token: ApplePayDataToken
    let billingContact: ApplePayAddressContact?
    let shippingContact: ApplePayAddressContact?
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

struct ApplePayAddressContact: Codable, Equatable {
    let phoneNumber: String?
    let emailAddress: String?
    let givenName: String?
    let familyName: String?
    let phoneticGivenName: String?
    let phoneticFamilyName: String?
    let addressLines: [String]?
    let subLocality: String?
    let locality: String?
    let postalCode: String?
    let subAdministrativeArea: String?
    let administrativeArea: String?
    let country: String?
    let countryCode: String?
}
