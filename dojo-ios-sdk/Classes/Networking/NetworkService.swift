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
        self.session = URLSession.shared
        self.timeout = timeout
    }
    
    func collectDeviceData(token: String,
                           payload: DojoCardPaymentPayload,
                           completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(token: token, endpoint: .deviceData) else {
            completion?(.error(ErrorBuilder.internalError(.cantBuildURL)))
            return
        }
        
        guard let bodyData = getCardRequestBody(payload: payload) else {
            completion?(.error(ErrorBuilder.internalError(.cantEncodePayload)))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            //TODO check for status code
            if let error = error {
                completion?(.error(error as NSError))
            } else {
                let decoder = JSONDecoder()
                if let data = data,
                   let decodedResponse = try? decoder.decode(DeviceDataResponse.self, from: data){
                    completion?(.deviceDataRequired(formAction: decodedResponse.formAction,
                                                    token: decodedResponse.token))
                } else {
                    completion?(.error(ErrorBuilder.internalError(.unknownError))) // TODO
                }
            }
        }
        task.resume()
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(token: token, endpoint: .cardPayment) else {
            completion?(.error(ErrorBuilder.internalError(.cantBuildURL)))
            return
        }
        
        guard let bodyData = getCardRequestBody(payload: payload) else {
            completion?(.error(ErrorBuilder.internalError(.cantEncodePayload)))
            return
        }
        
        let request = getDefaultPOSTRequest(url: url, body: bodyData, timeout: timeout)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(.error(error as NSError))
            } else if let data = data {
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode(ThreeDSResponse.self, from: data) {
                       if decodedResponse.statusCode == 0 { //TODO, 3DS has a code 3
                           completion?(.complete)
                           return
                       }
                    completion?(.threeDSRequired(stepUpUrl: decodedResponse.stepUpUrl,
                                                 jwt: decodedResponse.jwt,
                                                 md: decodedResponse.md))
                }
            } else {
                completion?(.error(ErrorBuilder.internalError(.unknownError)))
            }
        }
        // perform request
        task.resume()
    }
}

extension NetworkService {
    func getDefaultPOSTRequest(url: URL, body: Data, timeout: TimeInterval) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = timeout
        return request
    }
    
    func getCardRequestBody(payload: DojoCardPaymentPayload) -> Data? {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(CardPaymentDataRequest(payload: payload)) else {
            return nil
        }
        return bodyData
    }
}

struct DeviceDataResponse: Decodable {
    let formAction: String?
    let token: String?
}

struct CardPaymentDataRequest: Encodable {
    let cV2: String?
    let cardName: String?
    let cardNumber: String?
    let expiryDate: String?
    
    init(payload: DojoCardPaymentPayload) {
        cV2 = payload.cardDetails.cv2
        cardName = payload.cardDetails.cardName
        cardNumber = payload.cardDetails.cardNumber
        expiryDate = payload.cardDetails.expiryDate
    }
}

struct ThreeDSResponse: Decodable {
    let stepUpUrl: String?
    let jwt: String?
    let md: String?
    let statusCode: Int
}
