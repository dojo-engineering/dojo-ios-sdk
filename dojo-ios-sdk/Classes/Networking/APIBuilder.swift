//
//  APIBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum APIEndpoint {
    case cardPayment
    case deviceData
    case applePay
}

protocol APIBuilderProtocol {
    static func buildURL(_ isSandbox: Bool, token: String , endpoint: APIEndpoint) throws -> URL
}

struct APIBuilder: APIBuilderProtocol {
    static let hostSandbox = "https://web.e.test.connect.paymentsense.cloud/api/"
    static let host = "https://web.e.connect.paymentsense.cloud/api/"
    
    static func buildURL(_ isSandbox: Bool, token: String, endpoint: APIEndpoint) throws -> URL {
        // construct endpoint url
        var stringURL = isSandbox ? hostSandbox : host
        switch endpoint {
        case .cardPayment:
            stringURL += "payments/"
        case .deviceData:
            stringURL += "device-data/"
        case .applePay:
            stringURL += "payments/\(token)/apple-pay"
        }
        // append token, for apple pay it differs
        if endpoint != .applePay {
            stringURL += token
        }
        guard let url = URL(string: stringURL) else {
            throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)
        }
        return url
    }
}

