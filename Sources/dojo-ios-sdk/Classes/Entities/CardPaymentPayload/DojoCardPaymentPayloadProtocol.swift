//
//  DojoCardPaymentPayloadProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 02/08/2022.
//

import Foundation

protocol DojoCardPaymentPayloadProtocol: Codable {
    func getRequestBody() -> Data?
    func getMetadataSDKVersion() -> String
    func getMetadataSDKVersionKey() -> String
}

extension DojoCardPaymentPayloadProtocol {
    func getMetadataSDKVersion() -> String {
        "ios-\(DojoSDK.version())"
    }
    
    func getMetadataSDKVersionKey() -> String {
        "dojo-sdk-core-version"
    }
}
