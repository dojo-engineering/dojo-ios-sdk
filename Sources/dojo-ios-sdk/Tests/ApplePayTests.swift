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
        var applePayHandler = ApplePayHandler()
        var result = applePayHandler.convertAppleContactToServerContact(PKContact())
        XCTAssertEqual(result, result)
    }
}
