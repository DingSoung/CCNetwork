//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

extension URLRequest {
    public init?(method: HTTPMethod, url: String, parameters: [String: Any]? = nil, contentType: MIMEType? = nil) {
        guard let parameters = parameters else {
            self.init(method: method.raw, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            if parameters.isEmpty == false,
                let u = URL(string: url),
                var components = URLComponents(url: u, resolvingAgainstBaseURL: false) {
                let encodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.www_form_urlencoded
                components.percentEncodedQuery = encodedQuery
                if let encodeUrl = components.url?.absoluteString {
                    self.init(method: method.raw, url: encodeUrl, body: nil)
                    return
                }
            }
            self.init(method: method.raw, url: url, body: nil)
        case .post:
            let cType = contentType ?? .json
            let body: Data?
            switch cType {
            case .www_form_urlencoded:
                body = parameters.www_form_urlencoded.data(using: .utf8, allowLossyConversion: false)
            case .json:
                body = parameters.json
            }
            self.init(method: HTTPMethod.post.raw, url: url, body: body)
            self.setValue(cType.raw, forHTTPHeaderField: "Content-Type")
        }
    }
    public init?(method: String, url: String, body: Data?) {
        guard let url = URL(string: url) else { return nil }
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
