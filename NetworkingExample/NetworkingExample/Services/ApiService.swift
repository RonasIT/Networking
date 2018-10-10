//
//  Created by Dmitry Frishbuter on 27/09/2018
//  Copyright © 2018 Ronas IT. All rights reserved.
//

import Networking

final class ApiService: NetworkService, ApiServiceProtocol {

    @discardableResult
    func fetchSlideshow(success: @escaping (Slideshow) -> Void, failure: Failure?) -> Request<GeneralResponse>? {
        return request(for: AnythingEndpoint.fetchSlideshow, success: { (result: SlideshowResponse) in
            success(result.slideshow)
        }, failure: { error in
            failure?(error)
        })
    }

    @discardableResult
    func postContact(_ contact: Contact, success: @escaping (Contact) -> Void, failure: Failure?) -> Request<GeneralResponse>? {
        return request(for: AnythingEndpoint.postContact(contact), success: { (result: ContactResponse) in
            success(result.form)
        }, failure: { error in
            failure?(error)
        })
    }
}

private final class SlideshowResponse: Decodable {
    let slideshow: Slideshow
}

private final class ContactResponse: Decodable {
    let form: Contact
}
