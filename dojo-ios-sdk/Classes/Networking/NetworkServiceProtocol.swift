//
//  NetworkServiceProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum CardPaymentNetworkResponse {
    case threeDSRequired(stepUpUrl: String?, jwt: String?, md: String?)
    case deviceDataRequired(formAction: String?, token: String?)
    case result(Int)
}

protocol NetworkServiceProtocol {
    init(timeout: TimeInterval)
    func collectDeviceData(token: String,
                           payload: DojoCardPaymentPayloadProtocol,
                           completion: ((CardPaymentNetworkResponse) -> Void)?)
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayloadProtocol,
                            completion: ((CardPaymentNetworkResponse) -> Void)?)
    func performApplePayPayment(token: String,
                                payloads: (DojoApplePayPayload, ApplePayDataRequest), //TODO
                                completion: ((CardPaymentNetworkResponse) -> Void)?)
    func fetchPaymentIntent(intentId: String,
                            completion: ((String?, Error?) -> Void)?)
    func refreshPaymentIntent(intentId: String,
                              completion: ((String?, Error?) -> Void)?)
    func fetchCustomerPaymentMethods(customerId: String,
                                     customerSecret: String,
                                     completion: ((String?, Error?) -> Void)?)
    func deleteCustomerPaymentMethod(customerId: String,
                                     paymentMethodId: String,
                                     customerSecret: String,
                                     completion: ((String?, Error?) -> Void)?)
}
