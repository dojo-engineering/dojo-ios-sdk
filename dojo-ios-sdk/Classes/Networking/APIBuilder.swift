//
//  APIBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum APIEndpoint {
    case cardPayment
}

protocol APIBuilderProtocol {
    static func buildURL(_ endpoint: APIEndpoint) throws -> URL
}

struct APIBuilder: APIBuilderProtocol {
    static let host = "https://www.google.co.uk"
    
    static func buildURL(_ endpoint: APIEndpoint) throws -> URL {
        var stringURL = host
        switch endpoint {
        case .cardPayment:
            stringURL += "/cardPayment"
        }
        guard let url = URL(string: stringURL) else {
            throw ErrorBuilder.internalError(.cantBuildURL)
        }
        return url
    }
}

