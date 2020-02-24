//
// Created by Nikita Zatsepilov on 2019-01-17.
// Copyright (c) 2019 Ronas IT. All rights reserved.
//

public final class TokenRequestAdapter: RequestAdapter {

    private let accessTokenSupervisor: AccessTokenSupervisor

    public init(accessTokenSupervisor: AccessTokenSupervisor) {
        self.accessTokenSupervisor = accessTokenSupervisor
    }

    public func adapt(_ request: AdaptiveRequest) {
        guard request.endpoint.requiresAuthorization else {
            return
        }

        if let accessToken = accessTokenSupervisor.accessToken {
            Logging.log(type: .debug, category: .requestAdapting, "\(request) - Attaching access token: `\(accessToken)`")
            request.appendHeader(RequestHeaders.authorization(accessToken))
        } else {
            Logging.log(
                type: .fault,
                category: .requestAdapting,
                "\(request) - Attempt to attach access token, but access token is not exists"
            )
        }
    }
}
