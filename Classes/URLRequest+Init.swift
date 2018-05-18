//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

extension URLRequest {
    public enum HTTPMethod: Int {
        case get = 0, head, delete, post
    }
    public enum ContentType: Int {
        case www_form_urlencoded = 0, json
    }
}

extension URLRequest.HTTPMethod {
    init?(rawString: String) {
        switch rawString {
        case "GET": self = .get
        case "HEAD": self = .head
        case "DELETE": self = .delete
        case "POST": self = .post
        default:
            // unsupport type: "OPTIONS" "PUT" "PATCH" "TRACE" "CONNECT"
            return nil
        }
    }
    var rawString: String {
        switch self {
        case .get: return "GET"
        case .head: return "HEAD"
        case .delete: return "DELETE"
        case .post: return "POST"
        }
    }
}

extension URLRequest.ContentType {
    init?(rawString: String) {
        switch rawString {
        case "application/x-www-form-urlencoded": self = .www_form_urlencoded
        case "application/json": self = .json
        default:
            // unsupport type "charset=utf-8", "multipart/form-data", "text/xml"
            return nil
        }
    }
    var rawString: String {
        switch self {
        case .www_form_urlencoded: return "application/x-www-form-urlencoded"
        case .json: return "application/json"
        }
    }
}

extension URLRequest {
    public init?(method: HTTPMethod, url: String, parameters: [String: Any]? = nil, contentType: ContentType? = nil) {
        guard let parameters = parameters else {
            self.init(method: method.rawString, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            if parameters.isEmpty == false,
                let u = URL(string: url),
                var components = URLComponents(url: u, resolvingAgainstBaseURL: false) {
                let encodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + parameters.query
                components.percentEncodedQuery = encodedQuery
                if let encodeUrl = components.url?.absoluteString {
                    self.init(method: method.rawString, url: encodeUrl, body: nil)
                    return
                }
            }
            self.init(method: method.rawString, url: url, body: nil)
        case .post:
            let cType = contentType ?? .json
            let body: Data?
            switch cType {
            case .www_form_urlencoded:
                body = parameters.www_form_urlencoded
            case .json:
                body = parameters.json
            }
            self.init(method: HTTPMethod.post.rawString, url: url, body: body)
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

extension Dictionary where Key == String {
    public var query: String {
        var components: [(String, String)] = []
        for key in self.keys.sorted(by: <) {
            let value = self[key]!
            components += URLRequest.queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    public var json: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self)
        } catch let error {
            debugPrint(error.localizedDescription, self.debugDescription)
            return nil
        }
    }
    public var www_form_urlencoded: Data? {
        return self.query.data(using: .utf8, allowLossyConversion: false)
    }
}

// MARK: - parameter query, copy from alamofire
extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension URLRequest {
    private static func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        var escaped = ""
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                let substring = string[range]
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                index = endIndex
            }
        }
        return escaped
    }
    static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
}
