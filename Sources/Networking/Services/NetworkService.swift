//
//  Created by Dmitry Frishbuter on 27/09/2018
//  Copyright © 2018 Ronas IT. All rights reserved.
//

import Alamofire

public typealias Success<T> = (T) -> Void
public typealias Failure = (Error) -> Void

open class NetworkService {

    private let sessionManager: SessionManager
    private let requestAdaptingService: RequestAdaptingServiceProtocol?
    private let errorHandlingService: ErrorHandlingServiceProtocol?

    public init(sessionManager: SessionManager = .default,
                requestAdaptingService: RequestAdaptingServiceProtocol? = nil,
                errorHandlingService: ErrorHandlingServiceProtocol? = nil) {
        self.sessionManager = sessionManager
        self.requestAdaptingService = requestAdaptingService
        self.errorHandlingService = errorHandlingService
    }

    // MARK: - Private

    private func request<Result>(for endpoint: Endpoint,
                                 responseSerializer: DataResponseSerializer<Result>,
                                 success: @escaping Success<Result>,
                                 failure: @escaping Failure) -> CancellableRequest {
        let request = Request(sessionManager: sessionManager, endpoint: endpoint, responseSerializer: responseSerializer)
        return response(for: request, success: success, failure: failure)
    }

    private func uploadRequest<Result>(for endpoint: UploadEndpoint,
                                       responseSerializer: DataResponseSerializer<Result>,
                                       success: @escaping Success<Result>,
                                       failure: @escaping Failure) -> CancellableRequest {
        let request = UploadRequest(sessionManager: sessionManager, endpoint: endpoint, responseSerializer: responseSerializer)
        return response(for: request, success: success, failure: failure)
    }

    private func response<Result>(for request: BaseRequest<Result>,
                                  success: @escaping Success<Result>,
                                  failure: @escaping Failure) -> CancellableRequest {
        requestAdaptingService?.adapt(request)
        request.response { [weak self, weak request] response in
            guard let `self` = self, let `request` = request else {
                return
            }

            switch response.result {
            case .failure(let error):
                self.handleResponseError(error, response: response, request: request, failure: failure)
            case .success(let result):
                success(result)
            }
        }
        return request
    }

    private func handleResponseError<Result>(_ error: Error,
                                             response: DataResponse<Result>,
                                             request: BaseRequest<Result>,
                                             failure: @escaping Failure) {
        guard let errorHandlingService = errorHandlingService else {
            failure(error)
            return
        }

        let requestError = RequestError(endpoint: request.endpoint, underlyingError: error, response: response)
        errorHandlingService.handleError(requestError) { result in
            switch result {
            case .continueFailure(let error):
                failure(error)
            case .retryNeeded:
                request.retry()
            case .ignoreFailure:
                return
            }
        }
    }
}

// MARK: - Requests

extension NetworkService {

    @discardableResult
    public func request(for endpoint: Endpoint,
                        encoding: String.Encoding? = nil,
                        success: @escaping Success<String>,
                        failure: @escaping Failure) -> CancellableRequest {
        let responseSerializer = DataRequest.stringResponseSerializer(encoding: encoding)
        return request(for: endpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func request(for endpoint: Endpoint,
                        success: @escaping Success<Data>,
                        failure: @escaping Failure) -> CancellableRequest {
        let responseSerializer = DataRequest.dataResponseSerializer()
        return request(for: endpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func request<Object>(for endpoint: Endpoint,
                                decoder: JSONDecoder = JSONDecoder(),
                                success: @escaping Success<Object>,
                                failure: @escaping Failure) -> CancellableRequest where Object: Decodable {
        let responseSerializer: DataResponseSerializer<Object> = DataRequest.decodableResponseSerializer(with: decoder)
        return request(for: endpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func request<Key, Value>(for endpoint: Endpoint,
                                    readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                                    success: @escaping Success<[Key: Value]>,
                                    failure: @escaping Failure) -> CancellableRequest where Key: Hashable, Value: Any {
        let responseSerializer: DataResponseSerializer<[Key: Value]> = DataRequest.jsonResponseSerializer(with: readingOptions)
        return request(for: endpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }
}

// MARK: - Upload requests

extension NetworkService {

    @discardableResult
    public func uploadRequest(for uploadEndpoint: UploadEndpoint,
                              encoding: String.Encoding? = nil,
                              success: @escaping Success<String>,
                              failure: @escaping Failure) -> CancellableRequest {
        let responseSerializer = DataRequest.stringResponseSerializer(encoding: encoding)
        return uploadRequest(for: uploadEndpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func uploadRequest(for uploadEndpoint: UploadEndpoint,
                              success: @escaping Success<Data>,
                              failure: @escaping Failure) -> CancellableRequest {
        let responseSerializer = DataRequest.dataResponseSerializer()
        return uploadRequest(for: uploadEndpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func uploadRequest<Object>(for uploadEndpoint: UploadEndpoint,
                                      decoder: JSONDecoder = JSONDecoder(),
                                      success: @escaping Success<Object>,
                                      failure: @escaping Failure) -> CancellableRequest where Object: Decodable {
        let responseSerializer: DataResponseSerializer<Object> = DataRequest.decodableResponseSerializer(with: decoder)
        return uploadRequest(for: uploadEndpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }

    @discardableResult
    public func uploadRequest<Key, Value>(for uploadEndpoint: UploadEndpoint,
                                          readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                                          success: @escaping Success<[Key: Value]>,
                                          failure: @escaping Failure) -> CancellableRequest where Key: Hashable, Value: Any {
        let responseSerializer: DataResponseSerializer<[Key: Value]> = DataRequest.jsonResponseSerializer(with: readingOptions)
        return uploadRequest(for: uploadEndpoint, responseSerializer: responseSerializer, success: success, failure: failure)
    }
}
