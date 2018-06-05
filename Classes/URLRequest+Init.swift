//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

extension URLRequest {
    public init?(method: HTTPMethod, url: String, parameters: [String: Any]? = nil, contentType: MIMEType? = nil) {
        guard let url = URL(string: url) else {
            assertionFailure("invalid url")
            return nil
        }
        guard let parameters = parameters else {
            self.init(method: method.raw, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            guard let components = { () -> URLComponents? in
                var c = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let encodedQuery = (c?.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.wwwFormUrlEncoded
                c?.percentEncodedQuery = encodedQuery
                return c
                }(),
                let encodeUrl = components.url?.absoluteString,
                let url = URL(string: encodeUrl) else {
                    assertionFailure("invalid parameters")
                    return nil
            }
            self.init(method: method.raw, url: url, body: nil)
        case .post:
            let cType = contentType ?? .json
            let body: Data?
            switch cType {
            case .wwwFormUrlEncoded:
                body = parameters.wwwFormUrlEncoded.data(using: .utf8, allowLossyConversion: false)
            case .json:
                body = parameters.json
            }
            self.init(method: HTTPMethod.post.raw, url: url, body: body)
            self.setValue(cType.raw, forHTTPHeaderField: "Content-Type")
        }
    }

    public init(method: String, url: URL, body: Data?) {
        self.init(url: url)
        //request.cachePolicy
        self.timeoutInterval = 30
        //request.mainDocumentURL
        self.networkServiceType = URLRequest.NetworkServiceType.default
        self.allowsCellularAccess = true
        self.httpMethod = method
        [
            // Content-Type will be set automatic by data type
            // example:
            // "*/*": "Accept"
            // "application/x-www-form-urlencoded": "Content-Type"
            ].forEach { (key, value) in
                self.addValue(key, forHTTPHeaderField: value)
        }
        self.httpBody = body
        self.httpShouldHandleCookies = true
        self.httpShouldUsePipelining = true
    }
}
