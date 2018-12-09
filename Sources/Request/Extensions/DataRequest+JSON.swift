//
// Created by Nikita Zatsepilov on 07/12/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Alamofire

extension DataRequest {

    static func jsonResponseSerializer<Key, Value>(with readingOptions: JSONSerialization.ReadingOptions)
                    -> DataResponseSerializer<[Key: Value]> where Key: Hashable, Value: Any {
        return DataResponseSerializer { (request, response, data, error) -> Result<[Key: Value]> in
            if let error = error {
                return .failure(error)
            }

            guard let data = data else {
                let error = AFError.responseSerializationFailed(reason: .inputDataNil)
                return .failure(error)
            }

            do {
                let object = try JSONSerialization.jsonObject(with: data, options: readingOptions)
                guard let json = object as? [Key: Value] else {
                    return .failure(CocoaError.error(.keyValueValidation))
                }

                return .success(json)
            }
            catch {
                return .failure(error)
            }
        }
    }

    @discardableResult
    func responseJSON<Key, Value>(queue: DispatchQueue? = nil,
                                  readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                                  completionHandler: @escaping (DataResponse<[Key: Value]>) -> Void)
                    -> Self where Key: Hashable, Value: Any {
        let responseSerializer: DataResponseSerializer<[Key: Value]> =
                DataRequest.jsonResponseSerializer(with: readingOptions)
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
