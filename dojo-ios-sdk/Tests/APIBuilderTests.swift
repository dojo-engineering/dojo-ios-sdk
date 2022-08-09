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
            let url = try APIBuilder.buildURL(false, token: "token", endpoint: .cardPayment)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/payments/token")!)
            
            let sandboxUrl = try APIBuilder.buildURL(true, token: "token", endpoint: .cardPayment)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/payments/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSavedCardPayment() {
        do {
            let url = try APIBuilder.buildURL(false, token: "token", endpoint: .savedCardPayment)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/payments/recurring/token")!)
            
            let sandboxUrl = try APIBuilder.buildURL(true, token: "token", endpoint: .savedCardPayment)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/payments/recurring/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDataCollection() {
        do {
            let url = try APIBuilder.buildURL(false, token: "token", endpoint: .deviceData)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/device-data/token")!)
            
            let sandboxUrl = try APIBuilder.buildURL(true, token: "token", endpoint: .deviceData)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/device-data/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testApplePayPayment() {
        do {
            let url = try APIBuilder.buildURL(false, token: "token", endpoint: .applePay)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/cors/api/payments/token/apple-pay")!)
            
            let sandboxUrl = try APIBuilder.buildURL(true, token: "token", endpoint: .applePay)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/cors/api/payments/token/apple-pay")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}
