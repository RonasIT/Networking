//
// Created by Nikita Zatsepilov on 2019-01-18.
// Copyright (c) 2019 Ronas IT. All rights reserved.
//

import XCTest
import Networking
import Alamofire

final class TokenRefreshingTests: XCTestCase {

    private lazy var sessionService: MockSessionService = {
        return MockSessionService()
    }()

    private lazy var errorHandlingService: ErrorHandlingServiceProtocol = {
        return ErrorHandlingService(errorHandlers: [
            UnauthorizedErrorHandler(sessionService: sessionService)
        ])
    }()

    private lazy var requestAdaptingService: RequestAdaptingServiceProtocol = {
        return RequestAdaptingService(requestAdapters: [
            TokenRequestAdapter(sessionService: sessionService)
        ])
    }()

    private lazy var networkService: NetworkService = {
        return NetworkService(requestAdaptingService: requestAdaptingService,
                              errorHandlingService: errorHandlingService)
    }()
    
    private var request: CancellableRequest?

    override func tearDown() {
        super.tearDown()
        request = nil
        sessionService.clearToken()
    }

    func testTokenRefreshingWithRequestRetrying() {
        let tokenRefreshingStartedExpectation = expectation(description: "Expecting token refreshing")
        tokenRefreshingStartedExpectation.assertForOverFulfill = true
        let successResponseExpectation = expectation(description: "Expecting success in response")
        successResponseExpectation.assertForOverFulfill = true

        let newToken = "token"
        sessionService.tokenRefreshHandler = { success, _ in
            tokenRefreshingStartedExpectation.fulfill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                success?(newToken)
            }
        }
        request = networkService.request(for: HTTPBinEndpoint.bearer, success: { (response: BearerResponse) in
            XCTAssertTrue(response.authenticated)
            XCTAssertEqual(response.token, newToken)
            successResponseExpectation.fulfill()
        }, failure: { error in
            XCTFail("Invalid case")
        })

        let expectations = [tokenRefreshingStartedExpectation, successResponseExpectation]
        wait(for: expectations, timeout: 10, enforceOrder: true)
    }

    func testTokenRefreshingFailure() {
        let tokenRefreshingStartedExpectation = expectation(description: "Expecting token refresh")
        tokenRefreshingStartedExpectation.assertForOverFulfill = true
        let failureResponseExpectation = expectation(description: "Expecting failure in response")
        failureResponseExpectation.assertForOverFulfill = true

        let tokenRefreshError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))
        sessionService.tokenRefreshHandler = { _, failure in
            tokenRefreshingStartedExpectation.fulfill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                failure?(tokenRefreshError)
            }
        }
        request = networkService.request(for: HTTPBinEndpoint.bearer, success: { (response: BearerResponse) in
            XCTFail("Invalid case")
        }, failure: { error in
            failureResponseExpectation.fulfill()
        })

        let expectations = [tokenRefreshingStartedExpectation, failureResponseExpectation]
        wait(for: expectations, timeout: 10, enforceOrder: true)
    }
}

private final class BearerResponse: Codable {
    let authenticated: Bool
    let token: String
}
