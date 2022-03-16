//
//  NetworkServiceProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

enum CardPaymentNetworkResponse {
    case ThreeDSRequired
    case complete
    case error(NSError)
}

protocol NetworkServiceProtocol {
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?)
}

class NetworkService: NetworkServiceProtocol {
    
    let session: URLSession
    
    init() {
        self.session = URLSession.shared
    }
    
    func performCardPayment(token: String,
                            payload: DojoCardPaymentPayload,
                            completion: ((CardPaymentNetworkResponse) -> Void)?) {
        let url = try? APIBuilder.buildURL(token: token, endpoint: .cardPayment)
        var request = URLRequest(url: url!) // TODO
        request.setValue(
            "authToken",
            forHTTPHeaderField: "Authorization"
        )
        
        // Serialize HTTP Body data as JSON
        let encoder = JSONEncoder()
        let bodyData = try? encoder.encode(payload) // TODO handel try

        // Change the URLRequest to a POST request
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.timeoutInterval = 25
        
        let task = session.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print("")
            } else if let data = data {
                completion?(.ThreeDSRequired)
//                completion?(.error(ErrorBuilder.serverError(.threeDSError)))
            } else {
                print("")
            }
        }
        
        task.resume()
    }
}

