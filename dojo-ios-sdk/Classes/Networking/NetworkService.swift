//
//  NetworkService.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    let session: URLSession
    let timeout: TimeInterval
    
    required init(timeout: TimeInterval, session: URLSession) {
        self.session = session
        self.timeout = timeout
    }
    
    func collectDeviceData(token: String,
                           payload: DojoCardPaymentPayload,
                           completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(payload.isSandbox, token: token, endpoint: .deviceData) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = getCardRequestBody(payload: payload) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let _ = error {
                completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(DeviceDataResponse.self, from: data){
                    completion?(.deviceDataRequired(formAction: decodedResponse.formAction,
                                                    token: decodedResponse.token))
                } else {
                    completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
                }
            }
        }
        task.resume()
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(payload.isSandbox, token: token, endpoint: .cardPayment) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = getCardRequestBody(payload: payload) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error { // error
                completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            } else if let data = data {
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data) {
                    if decodedResponse.statusCode != SDKResponseCode.authorizing.rawValue { //TODO, 3DS has a code 3
                        completion?(.result(decodedResponse.statusCode))
                           return
                       }
                    completion?(.threeDSRequired(stepUpUrl: decodedResponse.stepUpUrl,
                                                 jwt: decodedResponse.jwt,
                                                 md: decodedResponse.md))
                } else { // can't decode
                    completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
                }
            } else { // no error and data is nil
                completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            }
        }
        // perform request
        task.resume()
    }
    
    func performApplePayPayment(token: String, payloads: (DojoApplePayPayload, ApplePayDataRequest), completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(payloads.0.isSandbox,
                                                 token: token,
                                                 endpoint: .applePay) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = getApplePayRequestBody(payload: payloads.1) else {
            completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let _ = error {
                completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data){
                    completion?(.result(decodedResponse.statusCode))
                } else {
                    completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
                }
            }
        }
        task.resume()
    }
}

extension NetworkService {
    func getDefaultPOSTRequest(url: URL, body: Data, timeout: TimeInterval) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = timeout
        request.setValue("true", forHTTPHeaderField: "IS_SANDBOX") 
        return request
    }
    
    static func getSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        return URLSession(configuration: configuration)
    }
    
    static func getMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession.init(configuration: configuration)
    }
    
    func getCardRequestBody(payload: DojoCardPaymentPayload) -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: payload)) else {
            return nil
        }
        return bodyData
    }
    
    func getApplePayRequestBody(payload: ApplePayDataRequest) -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(payload) else {
            return nil
        }
        return bodyData
    }
}

