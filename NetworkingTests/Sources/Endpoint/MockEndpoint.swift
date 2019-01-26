//
// Created by Nikita Zatsepilov on 2019-01-23.
// Copyright (c) 2019 Ronas IT. All rights reserved.
//

import Alamofire
import Networking

enum MockEndpoint: UploadEndpoint {
    case success
    case successUpload
    case failure
    case authorized
    case headersValidation([RequestHeader])
    case failureWithError(Error)

    var baseURL: URL {
        return URL(string: "localhost")!
    }

    var path: String {
        return "mock"
    }

    var method: HTTPMethod {
        switch self {
        case .successUpload:
            return .post
        default:
            return .get
        }
    }

    var headers: [RequestHeader] {
        return []
    }

    var parameters: Parameters? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    var requiresAuthorization: Bool {
        switch self {
        case .authorized:
            return true
        default:
            return false
        }
    }

    private var error: Error? {
        switch self {
        case .failureWithError(let error):
            return error
        default:
            return nil
        }
    }

    func error(forResponseCode responseCode: Int) -> Error? {
        return error
    }

    func error(forURLErrorCode errorCode: Int) -> Error? {
        return error
    }
}
