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
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        guard let url = try? APIBuilder.buildURL(token: token, endpoint: .cardPayment) else {
            completion?(.error(ErrorBuilder.internalError(.cantBuildURL)))
            return
        }
        // prepare request body
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(payload) else {
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
                completion?(.ThreeDSRequired)
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

