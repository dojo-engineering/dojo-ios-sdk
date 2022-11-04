//
//  APIBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum APIEndpointConnectE {
    case cardPayment
    case savedCardPayment
    case deviceData
    case applePay
}

enum APIEndpointDojo {
    case paymentIntent
    case paymentIntentRefresh
    case fetchCustomerPaymentMethods
    case deleteCustomerPaymentMethod
}

protocol APIBuilderProtocol {
    static func buildURLForConnectE(token: String, endpoint: APIEndpointConnectE) throws -> URL
    static func buildURLForDojo(pathComponents: [String], endpoint: APIEndpointDojo) throws -> URL
}

struct APIBuilder: APIBuilderProtocol {
    
    static let hostConnect = "https://web.e.connect.paymentsense.cloud/"
    static let hostDojo = "https://api.dojo.tech/"
    
    static func buildURLForConnectE(token: String, endpoint: APIEndpointConnectE) throws -> URL {
        // Requests to Connect-E
        var stringURL = hostConnect
        switch endpoint {
        case .cardPayment:
            stringURL += "api/payments/"
        case .savedCardPayment:
            stringURL += "api/payments/recurring/"
        case .deviceData:
            stringURL += "api/device-data/"
        case .applePay:
            stringURL += "cors/api/payments/\(token)/apple-pay"
        }
        // append token, for apple pay it differs
        if endpoint != .applePay {
            stringURL += token
        }

        return try buildURL(stringURL)
    }
    
    static func buildURLForDojo(pathComponents: [String], endpoint: APIEndpointDojo) throws -> URL {
        var stringURL = hostDojo
        switch endpoint {
        case .paymentIntent:
            guard let paymentId = pathComponents.first else { throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)}
            stringURL += "payment-intents/public/\(paymentId)"
        case .paymentIntentRefresh:
            guard let paymentId = pathComponents.first else { throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)}
            stringURL += "payment-intents/public/\(paymentId)/refresh-client-session-secret"
        case .fetchCustomerPaymentMethods:
            guard let customerId = pathComponents.first else { throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)}
            stringURL += "customers/public/\(customerId)/payment-methods"
        case .deleteCustomerPaymentMethod:
            guard let customerId = pathComponents.first,
                  let paymentMethodId = pathComponents.last else { throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)}
            stringURL += "customers/public/\(customerId)/payment-methods/\(paymentMethodId)"
        }
        return try buildURL(stringURL)
    }
    
    private static func buildURL(_ stringURL: String) throws -> URL {
        guard let url = URL(string: stringURL) else {
            throw ErrorBuilder.internalError(SDKResponseCode.sdkInternalError.rawValue)
        }
        return url
    }
}

