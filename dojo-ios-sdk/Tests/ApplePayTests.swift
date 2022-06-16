//
//  ApplePayTests.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import XCTest
@testable import dojo_ios_sdk
import PassKit

class ApplePayTests: XCTestCase {
    
    func testApplePay() {
        var applePayHandler = ApplePayHandler(networkService: NetworkService(timeout: 25,
                                                                             session: NetworkService.getMockSession()))
        
        MockURLProtocol.requestHandler = { request in
            let path = Bundle(for: ApplePayTests.self).url(forResource: "result-success", withExtension: "json")!
            let data = try! Data(contentsOf: path)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let networkService = NetworkService(timeout: 25, session: NetworkService.getMockSession())
        let dojoApplePayPayload = DojoApplePayPayload(applePayConfig: DojoApplePayConfig(merchantIdentifier: ""))
        let applePayDataRequest = ApplePayDataRequest(token: ApplePayDataToken(paymentData: ApplePayDataTokenPaymentData(data: "",
                                                                                                                         signature: "",
                                                                                                                         header: ApplePayDataTokenPaymentDataHeaders(publicKeyHash: "", ephemeralPublicKey: "", transactionId: ""),
                                                                                                                         version: ""),
                                                                               paymentMethod: ApplePayDataTokenPaymentMethod(displayName: "", network: "", type: ""),
                                                                               transactionIdentifier: ""),
                                                      billingContact: nil,
                                                      shippingContact: nil)
        networkService.performApplePayPayment(token: "22", payloads: (dojoApplePayPayload, applePayDataRequest)) { response in
            print(response)
        }
        var result = applePayHandler.convertAppleContactToServerContact(PKContact())
        XCTAssertEqual(result, result)
    }
}
