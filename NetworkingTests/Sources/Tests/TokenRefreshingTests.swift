//
// Created by Nikita Zatsepilov on 2019-01-18.
// Copyright (c) 2019 Ronas IT. All rights reserved.
//

@testable import Networking
import XCTest
import Alamofire

final class TokenRefreshingTests: XCTestCase {

    private lazy var sessionService: MockSessionService = {
        return MockSessionService()
    }()

    private lazy var errorHandlingService: ErrorHandlingServiceProtocol = {
        return ErrorHandlingService(errorHandlers: [
            UnauthorizedErrorHandler(accessTokenSupervisor: sessionService)
        ])
    }()

    private lazy var requestAdaptingService: RequestAdaptingServiceProtocol = {
        return RequestAdaptingService(requestAdapters: [
            TokenRequestAdapter(accessTokenSupervisor: sessionService)
        ])
    }()

    private lazy var networkService: NetworkService = {
        return MockNetworkService(requestAdaptingService: requestAdaptingService,
                                  errorHandlingService: errorHandlingService)
    }()

    override func tearDown() {
        super.tearDown()
        sessionService.clearToken()
    }

    func testTokenRefreshingWithSuccess() {
        let tokenRefreshingStartedExpectation = expectation(description: "Expecting token refreshing")
        tokenRefreshingStartedExpectation.assertForOverFulfill = true

        let successResponseExpectation = expectation(description: "Expecting success in response")
        successResponseExpectation.assertForOverFulfill = true
        successResponseExpectation.expectedFulfillmentCount = 10
        
        let maxRequestDelay: TimeInterval = 5
        let maxTokenRefreshingDelay: TimeInterval = 5
        
        sessionService.tokenRefreshHandler = { success, _ in
            let delay = TimeInterval.random(in: 1...maxTokenRefreshingDelay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                tokenRefreshingStartedExpectation.fulfill()
                success?(MockSessionService.Constants.validAccessToken)
            }
        }

        var endpoint = MockEndpoint()
        endpoint.requiresAuthorization = true
        endpoint.expectedAccessToken = MockSessionService.Constants.validAccessToken

        let array = [Int](0..<successResponseExpectation.expectedFulfillmentCount)
        let requests = array.map { _ -> CancellableRequest in
            endpoint.responseDelay = .random(in: 1...maxRequestDelay)
            return networkService.request(for: endpoint, success: {
                successResponseExpectation.fulfill()
            }, failure: { error in
                XCTFail("Invalid case")
            })
        }
        print("Testing \(requests.count) requests...")

        let expectations = [tokenRefreshingStartedExpectation, successResponseExpectation]
        let timeout = maxTokenRefreshingDelay + maxRequestDelay * 2
        wait(for: expectations, timeout: timeout + 1, enforceOrder: true)
    }

    func testTokenRefreshingWithFailure() {
        let tokenRefreshingStartedExpectation = expectation(description: "Expecting token refresh")
        tokenRefreshingStartedExpectation.assertForOverFulfill = true
        
        let failureResponseExpectation = expectation(description: "Expecting failure in response")
        failureResponseExpectation.assertForOverFulfill = true
        failureResponseExpectation.expectedFulfillmentCount = 10

        let maxRequestDelay: TimeInterval = 5
        let maxTokenRefreshingDelay: TimeInterval = 5
        
        let tokenRefreshError = MockError()
        sessionService.tokenRefreshHandler = { _, failure in
            let delay = TimeInterval.random(in: 1...maxTokenRefreshingDelay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                tokenRefreshingStartedExpectation.fulfill()
                failure?(tokenRefreshError)
            }
        }

        var endpoint = MockEndpoint()
        endpoint.requiresAuthorization = true
        endpoint.expectedAccessToken = MockSessionService.Constants.validAccessToken
        let array = [Int](0..<failureResponseExpectation.expectedFulfillmentCount)
        let requests = array.map { _ -> CancellableRequest in
            endpoint.responseDelay = .random(in: 1...maxRequestDelay)
            return networkService.request(for: endpoint, success: {
                XCTFail("Invalid case")
            }, failure: { error in
                if let error = error as? MockError {
                    XCTAssertFalse(error === tokenRefreshError, "Request shouldn't fail with error of token refreshing")
                }
                failureResponseExpectation.fulfill()
            })
        }
        print("Testing \(requests.count) requests...")

        let expectations = [tokenRefreshingStartedExpectation, failureResponseExpectation]
        let timeout = maxTokenRefreshingDelay + maxRequestDelay
        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func testUnauthorizedErrorHandlerWithUnsupportedError() {
        let errorHandler = UnauthorizedErrorHandler(accessTokenSupervisor: sessionService)
        let unsupportedError = MockError()
        let response: DataResponse<Any> = .init(request: nil, response: nil, data: nil, result: .failure(unsupportedError))
        let endpoint = MockEndpoint(result: unsupportedError)
        let requestError = RequestError(endpoint: endpoint, error: unsupportedError, response: response)

        let expectation = self.expectation(description: "Expecting continue error handling result")
        expectation.assertForOverFulfill = true
        errorHandler.handleError(requestError) { result in
            switch result {
            case .continueErrorHandling(with: let error as MockError) where error === unsupportedError:
                expectation.fulfill()
            default:
                XCTFail("Unexpected result")
            }
        }

        wait(for: [expectation], timeout: 3)
    }
}
