//
//  DojoCardPaymentPayloadProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 02/08/2022.
//

import Foundation

protocol DojoCardPaymentPayloadProtocol: Codable {
    func getRequestBody() -> Data?
}
