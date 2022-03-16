//
//  ErrorBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import XCTest
@testable import dojo_ios_sdk

class APIBuilderTests: XCTestCase {
    
    func testCardPayment() {
        do {
            let url = try APIBuilder.buildURL(token: "token", endpoint: .cardPayment)
            XCTAssertEqual(url, URL(string: "https://www.google.co.uk/v1/payments/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}
