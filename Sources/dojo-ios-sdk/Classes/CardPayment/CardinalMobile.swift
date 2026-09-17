//
//  CardinalPOC.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 27/06/2022.
//

import Foundation
import CardinalMobile

class CardinaMobile {
    
    var session : CardinalSession!
    var validationCompletion: ((String, ThreeDSCardinalValidateResponse) -> Void)?
    
    init(isSandbox: Bool = false) {
        setUp(isSandbox: isSandbox)
    }

    // Switch to Visa Data Center on 29 Oct 2026 00:00:00 UTC (48h safety buffer after Phase 1 begins)
    private static let visaCutoverDate = Date(timeIntervalSince1970: 1793232000)

    //Setup can be called in viewDidLoad
    func setUp(isSandbox: Bool) {
        session = CardinalSession()
        let config = CardinalSessionConfiguration()
        
        let isPreCutoverProduction = !isSandbox && Date() < Self.visaCutoverDate
        if isPreCutoverProduction {
            config.cardinalDatacenter = Cardinal
        } else {
            config.cardinalDatacenter = Visa
        }

        config.deploymentEnvironment = isSandbox ? .staging : .production
        config.requestTimeout = 8000
        config.challengeTimeout = 360
        config.uiType = .both
        config.renderType = [CardinalSessionRenderTypeOTP,
                                CardinalSessionRenderTypeHTML,
                                CardinalSessionRenderTypeOOB,
                                CardinalSessionRenderTypeSingleSelect,
                                CardinalSessionRenderTypeMultiSelect]

        session.configure(config)
        
        let warnings = session.getWarnings()
        print(warnings)
    }
    
    func startSession(jwt: String, completion: ((NSError?) -> Void)?) {
        session.setup(jwtString: jwt, completed: { (consumerSessionId: String) in
            completion?(nil)
        }) { (validateResponse: CardinalResponse) in
            completion?(NSError(domain: "cardinal-sdk", code: validateResponse.errorNumber))
        }
    }
    
    func performThreeDScheck(transactionId: String, payload: String, completion: ((String, ThreeDSCardinalValidateResponse) -> Void)?) {
        self.validationCompletion = completion
        self.session.continueWith(transactionId: transactionId, payload: payload, validationDelegate: self)
    }
    
}

extension CardinaMobile: CardinalValidationDelegate {
    func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
        let validatedResponse = ThreeDSCardinalValidateResponse(isValidated: validateResponse.isValidated,
                                                                errorNumber: validateResponse.errorNumber,
                                                                errorDescription: "",
                                                                actionCode: validateResponse.errorDescription.uppercased())
        self.validationCompletion?(serverJWT, validatedResponse)
    }
}
