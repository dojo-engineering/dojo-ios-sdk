//
//  CardinalPOC.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 27/06/2022.
//

import Foundation
import CardinalMobile

class CardinaMobilePOC {
    var session : CardinalSession!

    //Setup can be called in viewDidLoad
    func setupCardinalSession() {
        session = CardinalSession()
        let config = CardinalSessionConfiguration()
        config.deploymentEnvironment = .production
        config.requestTimeout = 8000
        config.challengeTimeout = 5
        config.uiType = .both

        let yourCustomUi = UiCustomization()
        //Set various customizations here. See "iOS UI Customization" documentation for detail.
        config.uiCustomization = yourCustomUi

        let yourDarkModeCustomUi = UiCustomization()
        config.uiCustomization = yourDarkModeCustomUi

        config.renderType = [CardinalSessionRenderTypeOTP,
                                CardinalSessionRenderTypeHTML,
                                CardinalSessionRenderTypeOOB,
                                CardinalSessionRenderTypeSingleSelect,
                                CardinalSessionRenderTypeMultiSelect]

        session.configure(config)
        
        let warnings = session.getWarnings()
        print(warnings)
        
        setupCardinalTransaction()
    }
    
    func setupCardinalTransaction() {
        let jwtString = "AKCp8mZT7bXrPdDNRwMHJ9y1QchvB8YcU1jBBWMHa9441nzgr1PxAYxuhL7yZRBUoPXJgvuvK"
//        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        
        session.setup(jwtString: jwtString, completed: { (consumerSessionId: String) in
            var a = 0
            //
            // You may have your Submit button disabled on page load. Once you are setup
            // for CCA, you may then enable it. This will prevent users from submitting
            // their order before CCA is ready.
            //
        }) { (validateResponse: CardinalResponse) in
            var a = 0
            // Handle failed setup
            // If there was an error with setup, cardinal will call this function with
            // validate response and empty serverJWT
        }
    }
}
