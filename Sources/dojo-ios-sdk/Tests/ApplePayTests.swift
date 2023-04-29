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
        let applePayHandler = ApplePayHandler()
        let result = applePayHandler.convertAppleContactToServerContact(PKContact())
        XCTAssertEqual(result, result)
    }
}
