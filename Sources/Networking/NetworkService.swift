//
//  Created by Dmitry Frishbuter on 27/09/2018
//  Copyright © 2018 Ronas IT. All rights reserved.
//

import Foundation
import Alamofire

public typealias Success<T> = (T) -> Void
public typealias Failure = (Error) -> Void

open class NetworkService {

    var errorHandlers: [ErrorHandler] = [GeneralErrorHandler()]

    private let sessionManager: SessionManager
    private let httpHeadersFactory: HTTPHeadersFactory

    public init(sessionManager: SessionManager = .default,
                httpHeadersFactory: HTTPHeadersFactory = GeneralHTTPHeadersFactory()) {
        self.sessionManager = sessionManager
        self.httpHeadersFactory = httpHeadersFactory
    }

    @discardableResult
    public func request<Object: Decodable>(for endpoint: Endpoint,
                                           decoder: JSONDecoder = JSONDecoder(),
                                           success: @escaping Success<Object>,
                                           failure: @escaping Failure) -> Request {
        let request = self.request(for: endpoint)
        request.responseDecodableObject(with: decoder, success: success, failure: failure)
        return request
    }

    @discardableResult
    public func request(for endpoint: Endpoint,
                        success: @escaping Success<String>,
                        failure: @escaping Failure) -> Request {
        let request = self.request(for: endpoint)
        request.responseString(success: success, failure: failure)
        return request
    }

    @discardableResult
    public func request(for endpoint: Endpoint,
                        success: @escaping Success<Data>,
                        failure: @escaping Failure) -> Request {
        let request = self.request(for: endpoint)
        request.responseData(success: success, failure: failure)
        return request
    }

    @discardableResult
    public func request(for endpoint: Endpoint,
                        readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                        success: @escaping Success<Any>,
                        failure: @escaping Failure) -> Request {
        let request = self.request(for: endpoint)
        request.responseJSON(with: readingOptions, success: success, failure: failure)
        return request
    }

    @discardableResult
    public func uploadRequest<Object: Decodable>(for endpoint: UploadEndpoint,
                                                 decoder: JSONDecoder = JSONDecoder(),
                                                 success: @escaping Success<Object>,
                                                 failure: @escaping Failure) -> Request {
        let request = self.uploadRequest(for: endpoint)
        request.responseDecodableObject(with: decoder, success: success, failure: failure)
        return request
    }

    @discardableResult
    public func uploadRequest(for endpoint: UploadEndpoint,
                              success: @escaping Success<String>,
                              failure: @escaping Failure) -> Request {
        let request = self.uploadRequest(for: endpoint)
        request.responseString(success: success, failure: failure)
        return request
    }

    @discardableResult
    public func uploadRequest(for endpoint: UploadEndpoint,
                              success: @escaping Success<Data>,
                              failure: @escaping Failure) -> Request {
        let request = self.uploadRequest(for: endpoint)
        request.responseData(success: success, failure: failure)
        return request
    }

    @discardableResult
    public func uploadRequest(for endpoint: UploadEndpoint,
                              readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                              success: @escaping Success<Any>,
                              failure: @escaping Failure) -> Request {
        let request = self.uploadRequest(for: endpoint)
        request.responseJSON(with: readingOptions, success: success, failure: failure)
        return request
    }

    public func authorization(for endpoint: Endpoint) -> RequestAuthorization {
        return .none
    }

    // MARK: - Private

    private func request(for endpoint: Endpoint) -> Request {
        let request = GeneralRequest(endpoint: endpoint,
                                     authorization: authorization(for: endpoint),
                                     sessionManager: sessionManager,
                                     httpHeadersFactory: httpHeadersFactory)
        request.errorHandlers = errorHandlers
        return request
    }

    private func uploadRequest(for endpoint: UploadEndpoint) -> Request {
        let request = GeneralUploadRequest(endpoint: endpoint,
                                           authorization: authorization(for: endpoint),
                                           sessionManager: sessionManager,
                                           httpHeadersFactory: httpHeadersFactory)
        request.errorHandlers = errorHandlers
        return request
    }
}
