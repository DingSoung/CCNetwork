//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation
import Extension

extension URLRequest {
    public init(method: HTTPMethod,
                url: URL,
                contentType: MIMEType = .json,
                parameters: [String: Any]? = nil,
                file: Data? = nil) {
        guard let parameters = parameters else {
            self.init(method: method.rawString, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let encodedQuery = (components?.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.wwwFormUrlEncoded
            components?.percentEncodedQuery = encodedQuery
            self.init(method: method.rawString, url: components?.url ?? url, body: nil)
        case .post:
            let body: Data?
            let contentTypeRaw: String
            switch contentType {
            case .wwwFormUrlEncoded:
                body = parameters.wwwFormUrlEncoded.data(using: .utf8, allowLossyConversion: false)
                contentTypeRaw = contentType.raw
            case .json:
                body = parameters.json
                contentTypeRaw = contentType.raw
            case .formData:
                let boundary = Date().timeIntervalSince1970.hashValue.description
                body = parameters.formData(boundary: boundary,
                                           name: (parameters["name"] as? String) ?? boundary,
                                           type: (parameters["type"] as? String) ?? "image",
                                           file: file ?? Data())
                contentTypeRaw = contentType.raw + "; boundary=\(boundary)"
            }
            self.init(method: HTTPMethod.post.rawString, url: url, body: body)
            self.setValue(contentTypeRaw, forHTTPHeaderField: "Content-Type")
        }
    }

    public init(method: String, url: URL, body: Data?) {
        self.init(url: url)
        //request.cachePolicy
        self.timeoutInterval = 30
        //request.mainDocumentURL
        self.networkServiceType = .default
        self.allowsCellularAccess = true
        self.httpMethod = method
        [
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
