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
    
    static func handle3DSFlow(stepUpUrl: String?,
                              jwt: String?,
                              md: String?,
                              fromViewController: UIViewController,
                              completion: ((NSError?) -> Void)?) {
        guard let stepUpUrl = stepUpUrl,
            let jwt = jwt,
            let md = md else {
            completion?(ErrorBuilder.internalError(.threeDSParamsNull))
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let threeDSController = ThreeDSViewController(stepUpUrl: stepUpUrl, md: md, jwt: jwt) { threeDS in
                fromViewController.dismiss(animated: true, completion: {
                    completion?(nil)
                })
            }
            fromViewController.present(threeDSController, animated: false, completion: nil)
        }
    }
}
