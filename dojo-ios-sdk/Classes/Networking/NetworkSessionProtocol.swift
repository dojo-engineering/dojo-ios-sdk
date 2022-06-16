//
//  NetworkSessionProtocol.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 20/05/2022.
//

import Foundation


class MockURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        // To check if this protocol can handle the given request.
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the canonical version of the request but most of the time you pass the orignal one.
        return request
    }
    
    // 1. Handler to test the request and return mock response.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override func startLoading() {
        
//        if request.url?.absoluteString.contains("device-data") ?? false {
//            MockURLProtocol.requestHandler = { request in
//                let jsonString = """
//                                 {
//                                 "hello":1
//                                 }
//                                 """
//                let data = jsonString.data(using: .utf8)
//                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//                return (response, data)
//            }
//        }
        
        
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            // 2. Call handler with received request and capture the tuple of response and data.
            let (response, data) = try handler(request)
            
            // 3. Send received response to the client.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                // 4. Send received data to the client.
                client?.urlProtocol(self, didLoad: data)
            }
            
            // 5. Notify request has been finished.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // 6. Notify received error.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}


//protocol NetworkSessionProtocol {
//    associatedtype DataTaskType
//    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTaskType
//}
//
////class NetworkSessionMock: NetworkSessionProtocol {
////    typealias DataTaskType = URLSessionDataTaskMock
////    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
////
////    var data: Data?
////    var error: Error?
////
////    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskMock {
////        URLSessionDataTaskMock(completion: completionHandler)
////    }
////}
//
//protocol URLSessionDataTaskProtocol {
//    var originalRequest: URLRequest? { get }
//    func resume()
//}
//
//extension URLSessionDataTask: URLSessionDataTaskProtocol {}
//
//typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
//
//protocol URLSessionProtocol {
//    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
//}
//
//extension URLSession: URLSessionProtocol {
//    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
//        let task:URLSessionDataTask = dataTask(with: request, completionHandler: {
//            (data:Data?, response:URLResponse?, error:Error?) in completionHandler(data,response,error) }) as URLSessionDataTask
//        return task
//    }
//}
