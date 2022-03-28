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
        }
        // append token
        stringURL += token
        guard let url = URL(string: stringURL) else {
            throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)
        }
        return url
    }
}

