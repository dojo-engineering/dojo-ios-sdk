//
//  ErrorBuilder.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 06/03/2022.
//

import XCTest
@testable import dojo_ios_sdk

class APIBuilderTests: XCTestCase {
    func test() {
        if let url = try? APIBuilder.buildURL(token: "token", endpoint: .cardPayment) {
            XCTAssertEqual(url, URL(string: "https://google.co.uk")!)
        }
        XCTAssertTrue(true)
    }
}
