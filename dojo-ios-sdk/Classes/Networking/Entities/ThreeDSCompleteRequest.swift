//
//  NetworkService.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import Foundation

struct ThreeDSResponse: Decodable {
    let stepUpUrl: String?
    let paReq: String?
    let md: String?
    let statusCode: Int
}
