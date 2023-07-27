//
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 22/08/2022.
//

import Foundation

extension DojoSDK {
    static func handleFetchCustomerPaymentMethods(customerId: String,
                                                  customerSecret: String,
                                                  debugConfig: DojoSDKDebugConfig?,
                                                  completion: ((String?, Error?) -> Void)?) {
        let networkService = NetworkService()
        networkService.fetchCustomerPaymentMethods(customerId: customerId, customerSecret: customerSecret, debugConfig: debugConfig) { result, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(result, error)
            }
        }
    }
    
    static func handleDeleteCustomerPaymentMethod(customerId: String,
                                                  paymentMethodId: String,
                                                  customerSecret: String,
                                                  debugConfig: DojoSDKDebugConfig?,
                                                  completion: ((Error?) -> Void)?) {
        let networkService = NetworkService()
        networkService.deleteCustomerPaymentMethod(customerId: customerId, paymentMethodId: paymentMethodId, customerSecret: customerSecret, debugConfig: debugConfig) { error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(error)
            }
        }
    }
}
