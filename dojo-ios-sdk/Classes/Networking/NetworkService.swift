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
                           completion: ((DeviceDataResponse?) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(token: token, endpoint: .deviceData) else {
//            completion?(.error(ErrorBuilder.internalError(.cantBuildURL)))
            return
        }
        
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(DeviceDataRequest(cV2: payload.cardDetails.cv2, cardName: payload.cardDetails.cardName, cardNumber: payload.cardDetails.cardNumber, expiryDate: payload.cardDetails.expiryDate)) else {
//            completion?(.error(ErrorBuilder.internalError(.cantEncodePayload)))
            return
        }
        
        // configure URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.timeoutInterval = timeout
        // configure task
        let task = session.dataTask(with: request) { (data, response, error) in
            print(String(decoding: data!, as: UTF8.self))
            let decoder = JSONDecoder()
            if let httpResponse = response as? HTTPURLResponse {
                  print("Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                let decodedResponse = try? decoder.decode(DeviceDataResponse.self, from: data)
                completion?(decodedResponse)
                var a = 0
            }
            
            
//            if let error = error {
//                completion?(.error(error as NSError))
//            } else if let data = data {
//                // TODO handle response from the BE
//                completion?(.ThreeDSRequired)
//            } else {
//                completion?(.error(ErrorBuilder.internalError(.unknownError)))
//            }
        }
        // perform request
        task.resume()
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(token: token, endpoint: .cardPayment) else {
            completion?(.error(ErrorBuilder.internalError(.cantBuildURL)))
            return
        }
        // prepare request body
        let encoder = JSONEncoder()
        
        guard let bodyData = try? encoder.encode(DeviceDataRequest(cV2: payload.cardDetails.cv2, cardName: payload.cardDetails.cardName, cardNumber: payload.cardDetails.cardNumber, expiryDate: payload.cardDetails.expiryDate)) else {
            completion?(.error(ErrorBuilder.internalError(.cantEncodePayload)))
            return
        }
        // configure URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.timeoutInterval = timeout
        // configure task
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(.error(error as NSError))
            } else if let data = data {
                // TODO handle response from the BE
                let str = String(decoding: data, as: UTF8.self)
                print(str)
//                completion?(.ThreeDSRequired)
            } else {
                completion?(.error(ErrorBuilder.internalError(.unknownError)))
            }
        }
        // perform request
        task.resume()
    }
}

//        request.setValue(
//            "authToken",
//            forHTTPHeaderField: "Authorization"
//        )



struct DeviceDataResponse: Decodable {
    let formAction: String?
    let token: String?
}

struct DeviceDataRequest: Encodable {
    let cV2: String?
    let cardName: String?
    let cardNumber: String?
    let expiryDate: String?
}
