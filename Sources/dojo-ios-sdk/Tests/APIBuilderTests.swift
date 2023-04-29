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
            let url = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .cardPayment, host: nil)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/payments/token")!)
            
            let sandboxUrl = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .cardPayment, host: nil)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/payments/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSavedCardPayment() {
        do {
            let url = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .savedCardPayment, host: nil)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/payments/recurring/token")!)
            
            let sandboxUrl = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .savedCardPayment, host: nil)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/payments/recurring/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDataCollection() {
        do {
            let url = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .deviceData, host: nil)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/api/device-data/token")!)
            
            let sandboxUrl = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .deviceData, host: nil)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/api/device-data/token")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testApplePayPayment() {
        do {
            let url = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .applePay, host: nil)
            XCTAssertEqual(url, URL(string: "https://web.e.connect.paymentsense.cloud/cors/api/payments/token/apple-pay")!)
            
            let sandboxUrl = try APIBuilder.buildURLForConnectE(token: "token", endpoint: .applePay, host: nil)
            XCTAssertEqual(sandboxUrl, URL(string: "https://web.e.test.connect.paymentsense.cloud/cors/api/payments/token/apple-pay")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFetchPaymentIntent() {
        do {
            let url = try APIBuilder.buildURLForDojo(pathComponents: ["payment-intent-id"], endpoint: .paymentIntent, host: nil)
            XCTAssertEqual(url, URL(string: "https://pay.dojo.tech/api/payment/payment-intent-id")!)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
