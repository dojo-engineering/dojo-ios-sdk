//
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 26/07/2023.
//

import Foundation

extension DojoSDK {
    static func handleSetupIntentFetching(intentId: String, debugConfig: DojoSDKDebugConfig?, completion: ((String?, Error?) -> Void)?) {
        let networkService = NetworkService()
        networkService.fetchSetupIntent(intentId: intentId, debugConfig: debugConfig) { paymentIntent, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(paymentIntent, error)
            }
        }
    }
    
    static func handleSetupIntentRefresh(intentId: String, debugConfig: DojoSDKDebugConfig?, completion: ((String?, Error?) -> Void)?) {
        let networkService = NetworkService()
        networkService.refreshSetupIntent(intentId: intentId, debugConfig: debugConfig) { paymentIntent, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(paymentIntent, error)
            }
        }
    }
}
