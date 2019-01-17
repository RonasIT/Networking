//
// Created by Nikita Zatsepilov on 03/12/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Alamofire

final class UploadRequest<Result>: BaseRequest<Result> {

    private let imageBodyParts: [ImageBodyPart]

    private var completion: Completion?
    private var isCancelled: Bool = false
    private var request: DataRequest?

    init(sessionManager: SessionManager, endpoint: UploadEndpoint, responseSerializer: DataResponseSerializer<Result>) {
        self.imageBodyParts = endpoint.imageBodyParts
        super.init(sessionManager: sessionManager, endpoint: endpoint, responseSerializer: responseSerializer)
    }

    override func response(completion: @escaping Completion) {
        self.completion = completion
        self.request = nil
        start(sending: { request in
            guard !self.isCancelled else {
                return
            }
            self.request = request
            request.response(responseSerializer: self.responseSerializer, completionHandler: completion)
        }, failure: { error in
            guard !self.isCancelled else {
                return
            }
            completion(DataResponse(request: nil, response: nil, data: nil, result: .failure(error)))
        })
    }

    override func retry() {
        if let completion = self.completion {
            response(completion: completion)
        }
    }

    override func cancel() {
        isCancelled = true
        request?.cancel()
        request = nil
        completion = nil
    }

    // MARK: - Private

    private func start(sending: @escaping (DataRequest) -> Void, failure: @escaping (Error) -> Void) {
        isCancelled = false
        let multipartFormDataHandler = { (multipartFormData: MultipartFormData) in
            multipartFormData.appendImageBodyParts(self.imageBodyParts)
            if let parameters = self.endpoint.parameters {
                multipartFormData.appendParametersBodyParts(parameters)
            }
        }
        let encodingCompletion = { (encodingResult: SessionManager.MultipartFormDataEncodingResult) in
            guard !self.isCancelled else {
                return
            }
            switch encodingResult {
            case .success(let request, _, _):
                request.validate()
                sending(request)
            case .failure(let error):
                failure(error)
            }
        }
        sessionManager.upload(multipartFormData: multipartFormDataHandler,
                              usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
                              to: endpoint.url,
                              method: .post,
                              headers: headers.httpHeaders,
                              encodingCompletion: encodingCompletion)
    }
}
