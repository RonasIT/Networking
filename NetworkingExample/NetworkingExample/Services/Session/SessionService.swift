//
// Created by Nikita Zatsepilov on 07/12/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Alamofire
import Networking

final class SessionService: SessionServiceProtocol {

    private var token: AuthToken?

    var authToken: AuthToken? {
        return token
    }

    func refreshAuthToken(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let `self` = self else {
                return
            }
            let expiryDate = Date(timeIntervalSinceNow: 24 * 60 * 60)
            self.token = AuthToken(token: "token", expiryDate: expiryDate)
        }
    }
}
