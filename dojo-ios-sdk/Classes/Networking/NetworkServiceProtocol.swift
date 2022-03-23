//
//  NetworkServiceProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum CardPaymentNetworkResponse {
    case ThreeDSRequired(ascUrl: String?, jwt: String?, md: String?, paReq: String?)
    case complete
    case error(NSError)
}

protocol NetworkServiceProtocol {
    init(timeout: TimeInterval)
    func collectDeviceData(token: String,
                           payload: DojoCardPaymentPayload,
                           completion: ((DeviceDataResponse?) -> Void)?)
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?)
}