//
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 22/08/2022.
//

import Foundation

extension DojoSDK {
    static func handleFetchCustomerPaymentMethods(customerId: String,
                                                  customerSecret: String,
                                                  completion: ((String?, Error?) -> Void)?) {
        let networkService = NetworkService(timeout: 25)
        networkService.fetchCustomerPaymentMethods(customerId: customerId, customerSecret: customerSecret) { result, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(result, error)
            }
        }
    }
    
    static func handleDeleteCustomerPaymentMethod(customerId: String,
                                                  paymentMethodId: String,
                                                  customerSecret: String,
                                                  completion: ((Error?) -> Void)?) {
        let networkService = NetworkService(timeout: 25)
        networkService.deleteCustomerPaymentMethod(customerId: customerId, paymentMethodId: paymentMethodId, customerSecret: customerSecret) { error in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion?(error)
            }
        }
    }
}
