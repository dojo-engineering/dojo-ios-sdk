//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

extension DojoSDK {
    static func handleDeviceDataCollection(token: String?,
                                    completion: ((NSError?) -> Void)?) {
        guard let token = token else {
            completion?(ErrorBuilder.internalError(.tokenNull))
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let dataCollectionController = DeviceDataCollectionViewController(token: token) { res in
                completion?(nil) // all good, we can continue // TODO document
            }
            dataCollectionController.viewDidLoad()
        }
    }
}
