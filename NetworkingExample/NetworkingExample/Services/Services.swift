//
// Created by Nikita Zatsepilov on 09/12/2018.
// Copyright (c) 2018 Ronas IT. All rights reserved.
//

import Networking

typealias HasServices = HasApiService &
                        HasSessionService &
                        HasApiRequestAdaptingService

var Services: HasServices = MainServices() // swiftlint:disable:this variable_name

final class MainServices: HasServices {

    lazy var sessionService: SessionServiceProtocol = {
        return SessionService()
    }()

    lazy var apiRequestAdaptingService: RequestAdaptingServiceProtocol = {
        return ApiRequestAdaptingService(sessionService: sessionService)
    }()

    lazy var apiErrorHandlingService: ErrorHandlingServiceProtocol = {
        return RequestErrorHandlingService(sessionService: sessionService)
    }()

    lazy var apiService: ApiServiceProtocol = {
        return ApiService(requestAdaptingService: apiRequestAdaptingService,
                          errorHandlingService: apiErrorHandlingService)
    }()
}
