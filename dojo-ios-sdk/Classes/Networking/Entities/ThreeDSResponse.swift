//
//  NetworkService.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

struct ThreeDSCompleteRequest: Codable {
    let paRes: String?
    let transactionId: String?
    let cardinalValidateResponse: ThreeDSCardinalValidateResponse
    
}

struct ThreeDSCardinalValidateResponse: Codable {
    let isValidated: Bool?
    let errorNumber: Int?
    let errorDescription: String?
    let actionCode: String?
}
