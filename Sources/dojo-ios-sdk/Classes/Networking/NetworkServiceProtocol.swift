//
//  NetworkServiceProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum CardPaymentNetworkResponse {
    case threeDSRequired(paReq: String, md: String)
    case deviceDataRequired(token: String)
    case result(Int)
}

protocol NetworkServiceProtocol {
    init(timeout: TimeInterval)
    func collectDeviceData(token: String,
                           payload: DojoCardPaymentPayloadProtocol,
                           debugConfig: DojoSDKDebugConfig?,
                           completion: ((CardPaymentNetworkResponse) -> Void)?)
    func submitThreeDSecurePayload(token: String,
                                   paRes: String,
                                   transactionId: String,
                                   cardinalValidateResponse: ThreeDSCardinalValidateResponse,
                                   debugConfig: DojoSDKDebugConfig?,
                                   completion: ((CardPaymentNetworkResponse) -> Void)?)
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayloadProtocol,
                            debugConfig: DojoSDKDebugConfig?,
                            completion: ((CardPaymentNetworkResponse) -> Void)?)
    func performApplePayPayment(token: String,
                                payloads: (DojoApplePayPayload, ApplePayDataRequest), //TODO
                                debugConfig: DojoSDKDebugConfig?,
                                completion: ((CardPaymentNetworkResponse) -> Void)?)
    func fetchPaymentIntent(intentId: String,
                            debugConfig: DojoSDKDebugConfig?,
                            completion: ((String?, Error?) -> Void)?)
    func fetchSetupIntent(intentId: String,
                          debugConfig: DojoSDKDebugConfig?,
                          completion: ((String?, Error?) -> Void)?)
    func refreshPaymentIntent(intentId: String,
                              debugConfig: DojoSDKDebugConfig?,
                              completion: ((String?, Error?) -> Void)?)
    func fetchCustomerPaymentMethods(customerId: String,
                                     customerSecret: String,
                                     debugConfig: DojoSDKDebugConfig?,
                                     completion: ((String?, Error?) -> Void)?)
    func deleteCustomerPaymentMethod(customerId: String,
                                     paymentMethodId: String,
                                     customerSecret: String,
                                     debugConfig: DojoSDKDebugConfig?,
                                     completion: ((Error?) -> Void)?)
}
