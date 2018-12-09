//
// Created by Nikita Zatsepilov on 09/12/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Alamofire

protocol NetworkRequest: BasicRequest, CancellableRequest, AdaptiveRequest {

    typealias Completion<T> = (T) -> Void

    var headers: [RequestHeader] { get set }

    func responseData(queue: DispatchQueue?, completion: @escaping Completion<DataResponse<Data>>)

    func responseJSON<Key: Hashable, Value: Any>(queue: DispatchQueue?,
                                                 readingOptions: JSONSerialization.ReadingOptions,
                                                 completion: @escaping Completion<DataResponse<[Key: Value]>>)

    func responseObject<Object: Decodable>(queue: DispatchQueue?,
                                           decoder: JSONDecoder,
                                           completion: @escaping Completion<DataResponse<Object>>)

    func responseString(queue: DispatchQueue?,
                        encoding: String.Encoding?,
                        completion: @escaping Completion<DataResponse<String>>)
}
