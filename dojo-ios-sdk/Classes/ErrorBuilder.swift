//
//  ErrorBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import Foundation

enum ErrorBuilderDomain: String {
    case internalError
    case serverError
}

enum InternalErrorCode: Int {
    case unknownError = 7770
    case cantBuildURL = 7771
    case cantEncodePayload = 7772
    case cancel = 0
}

enum ServerErrorCode: Int {
    case threeDSError = 881
    case applePayError = 880
}

protocol ErrorBuilderProtocol {
    static func internalError(_ code: InternalErrorCode) -> NSError
    static func serverError(_ error: NSError) -> NSError
    static func serverError(_ code: ServerErrorCode) -> NSError
}

struct ErrorBuilder: ErrorBuilderProtocol {
    
    static func internalError(_ code: InternalErrorCode) -> NSError {
        NSError(domain: ErrorBuilderDomain.internalError.rawValue, code: code.rawValue, userInfo: nil)
    }
    
    static func serverError(_ error: NSError) -> NSError {
        NSError(domain: ErrorBuilderDomain.serverError.rawValue, code: error.code, userInfo: nil)
    }
    
    static func serverError(_ code: ServerErrorCode) -> NSError {
        NSError(domain: ErrorBuilderDomain.serverError.rawValue, code: code.rawValue, userInfo: nil)
    }
}
