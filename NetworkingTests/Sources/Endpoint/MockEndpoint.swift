//
// Created by Nikita Zatsepilov on 2019-01-23.
// Copyright (c) 2019 Ronas IT. All rights reserved.
//

import Alamofire
import Networking

final class MockEndpoint: UploadEndpoint {

    enum Result {
        case failure(with: Error)
        case success(with: Data)
    }

    let result: Result

    var baseURL: URL = URL(string: "localhost")!
    var path: String = "mock"
    var method: HTTPMethod = .get
    var headers: [RequestHeader] = []
    var parameters: Parameters? = nil
    var parameterEncoding: ParameterEncoding = URLEncoding.default
    var requiresAuthorization: Bool = false
    var imageBodyParts: [ImageBodyPart] = []

    var errorForResponseCode: Error?
    var errorForURLErrorCode: Error?

    var expectedHeaders: [RequestHeader] = []
    var expectedAccessToken: String?

    init(result: String, encoding: String.Encoding = .utf8) {
        self.result = .success(with: result.data(using: encoding)!)
    }

    init(result: Data = Data()) {
        self.result = .success(with: result)
    }

    init(result: [String: Any], options: JSONSerialization.WritingOptions = .prettyPrinted) {
        self.result = .success(with: try! JSONSerialization.data(withJSONObject: result, options: options))
    }

    init<T>(result: T, encoder: JSONEncoder = JSONEncoder()) where T: Codable {
        self.result = .success(with: try! encoder.encode(result))
    }

    init(result: Error) {
        self.result = .failure(with: result)
    }

    func error(for urlErrorCode: URLError.Code) -> Error? {
        return errorForURLErrorCode
    }

    func error(forResponseCode responseCode: Int) -> Error? {
        return errorForResponseCode
    }
}
