//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

@objc
extension Network {

    @objc public enum HTTPMethod: Int {
        case options = 0, get, head, post, put, patch, delete, trace, connect
    }
    @nonobjc private static let HTTPMethodDict: [HTTPMethod: String] = [
        .options: "OPTIONS",
        .get: "GET",
        .head: "HEAD",
        .post: "POST",
        .put: "PUT",
        .patch: "PATCH",
        .delete: "DELETE",
        .trace: "TRACE",
        .connect: "CONNECT"
    ]

    @objc @discardableResult open class func request(session: URLSession = Network.shareSession,
                                                     method: HTTPMethod,
                                                     url: String,
                                                     parameters: [String: Any],
                                                     complete: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionDataTask? {
        return Network.data(session: session,
                            url: url,
                            method: HTTPMethodDict[method] ?? "OPTIONS",
                            parameters: parameters,
                            complete: complete)
    }
}
