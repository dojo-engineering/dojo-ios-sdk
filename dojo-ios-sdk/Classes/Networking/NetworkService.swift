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
    
    required init(timeout: TimeInterval) {
        self.session = NetworkService.getSesstion()
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
            if let _ = error {
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
                }
            } else {
                completion?(.result(SDKResponseCode.sdkInternalError.rawValue))
            }
        }
        // perform request
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
        return request
    }
    
    static func getSesstion() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        return URLSession(configuration: configuration)
    }
    
    func getCardRequestBody(payload: DojoCardPaymentPayload) -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: payload)) else {
            return nil
        }
        return bodyData
    }
}
