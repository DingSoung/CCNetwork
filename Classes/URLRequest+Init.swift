//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

#if os(iOS)
import Extension
#endif

#if os(watchOS)
import Extension_watchOS
#endif

#if os(macOS)
import Extension_macOS
#endif

#if os(tvOS)
import Extension_tvOS
#endif

extension URLRequest {
    public init(method: HTTPMethod, url: URL, parameters: [String: Any]? = nil, contentType: MIMEType? = nil) {
        guard let parameters = parameters else {
            self.init(method: method.raw, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let encodedQuery = (components?.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.wwwFormUrlEncoded
            components?.percentEncodedQuery = encodedQuery
            self.init(method: method.raw, url: components?.url ?? url, body: nil)
        case .post:
            let cType = contentType ?? .json
            let body: Data?
            let contentTypeRaw: String
            switch cType {
            case .wwwFormUrlEncoded:
                body = parameters.wwwFormUrlEncoded.data(using: .utf8, allowLossyConversion: false)
                contentTypeRaw = cType.raw
            case .json:
                body = parameters.json
                contentTypeRaw = cType.raw
            case .formData:
                let boundary = Date().timeIntervalSince1970.hashValue.description
                body = parameters.formData(boundary: boundary, name: "1", type: "image", file: Data())
                contentTypeRaw = cType.raw + "; boundary=\(boundary)"
            }
            self.init(method: HTTPMethod.post.raw, url: url, body: body)
            self.setValue(contentTypeRaw, forHTTPHeaderField: "Content-Type")
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
