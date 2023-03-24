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
                           payload: DojoCardPaymentPayloadProtocol,
                           completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForConnectE(token: token, endpoint: .deviceData) else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = payload.getRequestBody() else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let _ = error {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(DeviceDataResponse.self, from: data),
                   let token = decodedResponse.token {
                    completion?(.deviceDataRequired(token: token))
                } else {
                    completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                }
            }
        }
        task.resume()
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayloadProtocol,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        let endpoint: APIEndpointConnectE = (payload as? DojoSavedCardPaymentPayload) != nil ? .savedCardPayment : .cardPayment
        
        guard let url = try? APIBuilder.buildURLForConnectE(token: token, endpoint: endpoint) else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = payload.getRequestBody() else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error { // error
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            } else if let data = data {
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data) {
                    if decodedResponse.statusCode != DojoSDKResponseCode.authorizing.rawValue { //TODO, 3DS has a code 3
                        completion?(.result(decodedResponse.statusCode))
                           return
                       }
                    if let paReq = decodedResponse.paReq, let md = decodedResponse.md {
                        completion?(.threeDSRequired(paReq: paReq,
                                                     md: md))
                    } else {
                        completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                    }
                } else { // can't decode
                    completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                }
            } else { // no error and data is nil
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            }
        }
        // perform request
        task.resume()
    }
    
    func submitThreeDSecurePayload(token: String, paRes: String, transactionId: String, cardinalValidateResponse: ThreeDSCardinalValidateResponse, isSandbox: Bool, completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForConnectE(token: token,
                                                            endpoint: .threeDSecureComplete) else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(
            ThreeDSCompleteRequest(paRes: paRes, transactionId: transactionId,
                                   cardinalValidateResponse: cardinalValidateResponse)) else {
            return
        }

        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let _ = error {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data){
                    completion?(.result(decodedResponse.statusCode))
                } else {
                    completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                }
            }
        }
        task.resume()
    }
    
    func performApplePayPayment(token: String, payloads: (DojoApplePayPayload, ApplePayDataRequest), completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForConnectE(token: token,
                                                            endpoint: .applePay) else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        guard let bodyData = getApplePayRequestBody(payload: payloads.1) else {
            completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let _ = error {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data){
                    completion?(.result(decodedResponse.statusCode))
                } else {
                    completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                }
            }
        }
        task.resume()
    }
    
    func fetchPaymentIntent(intentId: String, completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [intentId],
                                                        endpoint: .paymentIntent) else {
            completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        let request = getDefaultGETRequest(url: url, timeout: timeout)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { // Error from request
                completion?(nil, error)
            } else if let data = data, // Data is available
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 { // Request has a success code
                let responseString = String(decoding: data, as: UTF8.self)
                completion?(responseString, nil)
            } else { // No error and no data
                completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            }
        }
        task.resume()
    }
    
    func refreshPaymentIntent(intentId: String,
                              completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [intentId],
                                                        endpoint: .paymentIntentRefresh) else {
            completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        let request = getDefaultPOSTRequest(url: url, body: nil, timeout: timeout)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { // Error from request
                completion?(nil, error)
            } else if let data = data, // Data is available
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 { // Request has a success code
                let responseString = String(decoding: data, as: UTF8.self)
                completion?(responseString, nil)
            } else { // No error and no data
                completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            }
        }
        task.resume()
    }
    
    func fetchCustomerPaymentMethods(customerId: String, customerSecret: String, completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [customerId],
                                                        endpoint: .fetchCustomerPaymentMethods) else {
            completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        let request = getDefaultGETRequest(url: url, timeout: timeout, auth: customerSecret)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { // Error from request
                completion?(nil, error)
            } else if let data = data, // Data is available
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 { // Request has a success code
                let responseString = String(decoding: data, as: UTF8.self)
                completion?(responseString, nil)
            } else { // No error and no data
                completion?(nil, ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            }
        }
        task.resume()
    }
    
    func deleteCustomerPaymentMethod(customerId: String, paymentMethodId: String, customerSecret: String, completion: ((Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [customerId, paymentMethodId],
                                                        endpoint: .deleteCustomerPaymentMethod) else {
            completion?(ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            return
        }
        var request = getDefaultGETRequest(url: url, timeout: timeout, auth: customerSecret)
        request.httpMethod = HTTPMethod.DELETE
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { // Error from request
                completion?(error)
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 204 { // Request has a success code
                completion?(nil)
            } else { // No error and no data
                completion?(ErrorBuilder.internalError(DojoSDKResponseCode.sdkInternalError.rawValue))
            }
        }
        task.resume()
    }
}

extension NetworkService {
    
    enum HTTPMethod {
        static let POST = "POST"
        static let GET = "GET"
        static let DELETE = "DELETE"
    }
    
    func getDefaultPOSTRequest(url: URL, body: Data?, timeout: TimeInterval) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = HTTPMethod.POST
        request.httpBody = body
        request.timeoutInterval = timeout
        request.addValue("2022-04-07", forHTTPHeaderField: "Version")
        request.addValue("true", forHTTPHeaderField: "IS-MOBILE")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func getDefaultGETRequest(url: URL, timeout: TimeInterval, auth: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = HTTPMethod.GET
        request.timeoutInterval = timeout
        request.addValue("2022-04-07", forHTTPHeaderField: "Version")
        request.addValue("true", forHTTPHeaderField: "IS-MOBILE")
        if let auth = auth {
            request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func getSesstion() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        return URLSession(configuration: configuration)
    }
    
    func getApplePayRequestBody(payload: ApplePayDataRequest) -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(payload) else {
            return nil
        }
        return bodyData
    }
}