//
// Created by Nikita Zatsepilov on 30/11/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Foundation
import Alamofire

final class GeneralRequest: NetworkRequest {

    public let endpoint: Endpoint

    private(set) var additionalHeaders: [RequestHeader] = []

    private let sessionManager: SessionManager
    private var request: DataRequest?

    init(sessionManager: SessionManager = .default,
         endpoint: Endpoint) {
        self.endpoint = endpoint
        self.sessionManager = sessionManager
    }

    func responseObject<Object: Decodable>(queue: DispatchQueue? = nil,
                                           decoder: JSONDecoder,
                                           completion: @escaping Completion<DataResponse<Object>>) {
        request = makeRequest()
        request?.responseObject(queue: queue, decoder: decoder, completionHandler: completion)
    }

    func responseString(queue: DispatchQueue? = nil,
                        encoding: String.Encoding? = nil,
                        completion: @escaping Completion<DataResponse<String>>) {
        request = makeRequest()
        request?.responseString(queue: queue, encoding: encoding, completionHandler: completion)
    }

    func responseJSON<Key: Hashable, Value>(queue: DispatchQueue? = nil,
                                            readingOptions: JSONSerialization.ReadingOptions,
                                            completion: @escaping Completion<DataResponse<[Key: Value]>>) {
        request = makeRequest()
        request?.responseJSON(queue: queue, readingOptions: readingOptions, completionHandler: completion)
    }

    func responseData(queue: Dispatch.DispatchQueue? = nil,
                      completion: @escaping Completion<DataResponse<Data>>) {
        request = makeRequest()
        request?.responseData(queue: queue, completionHandler: completion)
    }

    func cancel() {
        request?.cancel()
    }

    func addHeader(_ header: RequestHeader) {
        // TODO: find way to move to `NetworkRequest` protocol
        let headerIndexOrNil = additionalHeaders.firstIndex { existingHeader in
            return existingHeader.key == header.key
        }

        if let headerIndex = headerIndexOrNil {
            additionalHeaders.remove(at: headerIndex)
        }

        additionalHeaders.append(header)
    }

    // MARK: Private

    private func makeRequest() -> DataRequest {
        return sessionManager.request(endpoint.url,
                                      method: endpoint.method,
                                      parameters: endpoint.parameters,
                                      encoding: endpoint.parameterEncoding,
                                      headers: httpHeaders).validate()
    }
}
