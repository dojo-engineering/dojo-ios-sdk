//
//  DojoSDK.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import UIKit

extension DojoSDK {
    static func handleDeviceDataCollection(token: String?,
                                           formAction: String?,
                                           completion: ((Int?) -> Void)?) {
        guard let token = token, let formAction = formAction else {
            completion?(SDKResponseCode.sdkInternalError.rawValue)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let dataCollectionController = DeviceDataCollectionViewController(token: token,
                                                                              formAction: formAction) { res in
                completion?(nil) // all good, we can continue // TODO document
            }
            dataCollectionController.viewDidLoad()
        }
    }
    
    static func handle3DSFlow(stepUpUrl: String?,
                              jwt: String?,
                              md: String?,
                              fromViewController: UIViewController,
                              completion: ((Int) -> Void)?) {
        guard let stepUpUrl = stepUpUrl,
            let jwt = jwt,
            let md = md else {
            completion?(SDKResponseCode.sdkInternalError.rawValue)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let threeDSController = ThreeDSViewController(stepUpUrl: stepUpUrl, md: md, jwt: jwt) { resultCode in
                fromViewController.dismiss(animated: true, completion: {
                    completion?(resultCode)
                })
            }
            fromViewController.present(threeDSController, animated: false, completion: nil)
        }
    }
}
