//
//  ErrorBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import Foundation

enum ErrorBuilderDomain: String {
    case internalError
}

enum SDKResponseCode: Int {
    case successful = 0
    case authorizing = 3
    case referred = 4
    case declined = 5
    case duplicateTransaction = 20
    case failed = 30
    case waitingPreExecute = 99
    case invalidRequest = 400
    case issueWithAccessToken = 401
    case noAccessTokenSupplied = 404
    case internalServerError = 500
    
    case sdkInternalError = 7770
}

protocol ErrorBuilderProtocol {
    static func internalError(_ code: Int) -> NSError
}

// TODO not in use anymore
struct ErrorBuilder: ErrorBuilderProtocol {
    static func internalError(_ code: Int) -> NSError {
        NSError(domain: ErrorBuilderDomain.internalError.rawValue, code: code, userInfo: nil)
    }
}
