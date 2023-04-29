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
                           debugConfig: DojoSDKDebugConfig?,
                           completion: ((CardPaymentNetworkResponse) -> Void)?) {
        fetchRegionalURL { regionalURL in
            let hostURL = debugConfig?.urlConfig?.connectE ?? regionalURL
            
            guard let url = try? APIBuilder.buildURLForConnectE(token: token, endpoint: .deviceData, host: hostURL) else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            guard let bodyData = payload.getRequestBody() else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            let request = self.getDefaultPOSTRequest(url: url, body: bodyData, timeout: self.timeout)
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
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
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayloadProtocol,
                            debugConfig: DojoSDKDebugConfig?,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        
        fetchRegionalURL { regionalURL in
            let hostURL = debugConfig?.urlConfig?.connectE ?? regionalURL
            
            let endpoint: APIEndpointConnectE = (payload as? DojoSavedCardPaymentPayload) != nil ? .savedCardPayment : .cardPayment
            
            guard let url = try? APIBuilder.buildURLForConnectE(token: token, endpoint: endpoint, host: hostURL) else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            guard let bodyData = payload.getRequestBody() else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            let request = self.getDefaultPOSTRequest(url: url, body: bodyData, timeout: self.timeout)
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
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
        
        
    }
    
    func submitThreeDSecurePayload(token: String, paRes: String, transactionId: String, cardinalValidateResponse: ThreeDSCardinalValidateResponse, debugConfig: DojoSDKDebugConfig?, completion: ((CardPaymentNetworkResponse) -> Void)?) {
        fetchRegionalURL { regionalURL in
            let hostURL = debugConfig?.urlConfig?.connectE ?? regionalURL
            guard let url = try? APIBuilder.buildURLForConnectE(token: token,
                                                                endpoint: .threeDSecureComplete,
                                                                host: hostURL) else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            let encoder = JSONEncoder()
            guard let bodyData = try? encoder.encode(
                ThreeDSCompleteRequest(paRes: paRes, transactionId: transactionId,
                                       cardinalValidateResponse: cardinalValidateResponse)) else {
                return
            }

            let request = self.getDefaultPOSTRequest(url: url, body: bodyData, timeout: self.timeout)
            let task = self.session.dataTask(with: request) { (data, response, error) in
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
    }
    
    func performApplePayPayment(token: String, payloads: (DojoApplePayPayload, ApplePayDataRequest), debugConfig: DojoSDKDebugConfig?, completion: ((CardPaymentNetworkResponse) -> Void)?) {
        fetchRegionalURL { regionalURL in
            let hostURL = debugConfig?.urlConfig?.connectE ?? regionalURL
            guard let url = try? APIBuilder.buildURLForConnectE(token: token,
                                                                endpoint: .applePay,
                                                                host: hostURL) else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            guard let bodyData = self.getApplePayRequestBody(payload: payloads.1) else {
                completion?(.result(DojoSDKResponseCode.sdkInternalError.rawValue))
                return
            }
            
            let request = self.getDefaultPOSTRequest(url: url, body: bodyData, timeout: self.timeout)
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
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
    }
    
    func fetchPaymentIntent(intentId: String, debugConfig: DojoSDKDebugConfig?, completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [intentId],
                                                        endpoint: .paymentIntent,
                                                        host: debugConfig?.urlConfig?.remote) else {
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
                              debugConfig: DojoSDKDebugConfig?,
                              completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [intentId],
                                                        endpoint: .paymentIntentRefresh,
                                                        host: debugConfig?.urlConfig?.remote) else {
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
    
    func fetchCustomerPaymentMethods(customerId: String, customerSecret: String, debugConfig: DojoSDKDebugConfig?, completion: ((String?, Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [customerId],
                                                        endpoint: .fetchCustomerPaymentMethods,
                                                        host: debugConfig?.urlConfig?.remote) else {
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
    
    func deleteCustomerPaymentMethod(customerId: String, paymentMethodId: String, customerSecret: String, debugConfig: DojoSDKDebugConfig?, completion: ((Error?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForDojo(pathComponents: [customerId, paymentMethodId],
                                                        endpoint: .deleteCustomerPaymentMethod,
                                                        host: debugConfig?.urlConfig?.remote) else {
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

extension NetworkService {
    private func fetchRegionalURL(completion: ((String?) -> Void)?) {
        internalFetchRegionalURL(endpoint: .gcp, completion: { urlGCP, dateGCP in
            self.internalFetchRegionalURL(endpoint: .aws, completion: { urlAWS, dateAWS in
                // if GCP URL is nil, return AWS url
                guard let urlCGP = urlGCP, let dateGCP = dateGCP else {
                    completion?(urlAWS)
                    return
                }
                // if AWS URL is nil, return GCP url
                guard let urlAWS = urlAWS, let dateAWS = dateAWS else {
                    completion?(urlCGP)
                    return
                }
                // if both exist, compare the last modify
                let returnURL = dateGCP > dateAWS ? urlCGP : urlAWS
                completion?(returnURL)
            })
        })
    }
    
    private func internalFetchRegionalURL(endpoint: APIEndpointRegional, completion: ((String?, Date?) -> Void)?) {
        guard let url = try? APIBuilder.buildURLForExternalConfig(endpoint: endpoint) else {
            completion?(nil, nil)
            return
        }
        
        let request = getDefaultGETRequest(url: url, timeout: timeout)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                completion?(nil, nil)
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(RegionalManifestEntity.self, from: data),
                   let responseConverted = response as? HTTPURLResponse,
                   let lastModify = responseConverted.allHeaderFields["Last-Modified"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
                        dateFormatter.locale = Locale(identifier: "en")
                        let serverDate = dateFormatter.date(from: lastModify)
                        completion?(decodedResponse.baseUrl, serverDate)
                } else {
                    completion?(nil, nil)
                }
            }
        }
        task.resume()
    }
    
    private struct RegionalManifestEntity: Decodable {
        let format: String?
        let baseUrl: String?
        let baseClientEventUrl: String?
    }
}
