//
//  NetworkService.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 22/08/2022.
//

import Foundation

extension DojoSDK {
    static func handlePaymentIntentFetching(intentId: String, completion: ((String?, Error?) -> Void)?) {
        let networkService = NetworkService(timeout: 25)
        networkService.fetchPaymentIntent(intentId: intentId) { paymentIntent, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(paymentIntent, error)
            }
        }
    }
}
