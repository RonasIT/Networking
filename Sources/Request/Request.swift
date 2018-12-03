//
//  Created by Dmitry Frishbuter on 27/09/2018
//  Copyright © 2018 Ronas IT. All rights reserved.
//

import Alamofire

public enum RequestAuthorization {
    case none
    case token(String)
}

public protocol ErrorHandler {
    func handle<T>(error: inout Error, for response: DataResponse<T>?, endpoint: Endpoint) -> Bool
}

public protocol BasicRequest: AnyObject {

    var endpoint: Endpoint { get }
    var authorization: RequestAuthorization  { get }
    var errorHandlers: [ErrorHandler] { get set }
}

public protocol Request: BasicRequest {

    typealias SuccessHandler<T> = (T) -> Void
    typealias FailureHandler = (Error) -> Void

    func responseString(success: @escaping SuccessHandler<String>,
                        failure: @escaping FailureHandler)

    func responseDecodableObject<Object: Decodable>(with decoder: JSONDecoder,
                                                    success: @escaping SuccessHandler<Object>,
                                                    failure: @escaping FailureHandler)

    func responseJSON(with readingOptions: JSONSerialization.ReadingOptions,
                      success: @escaping SuccessHandler<Any>,
                      failure: @escaping FailureHandler)

    func responseData(success: @escaping SuccessHandler<Data>,
                      failure: @escaping FailureHandler)

    func cancel()
}
