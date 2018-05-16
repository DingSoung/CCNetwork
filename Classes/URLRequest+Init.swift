//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

extension URLRequest {
    public enum HTTPMethod: Int {
        case options = 0, get, head, post, put, patch, delete, trace, connect
    }
}

extension URLRequest.HTTPMethod {
    init?(rawString: String) {
        switch rawString {
        case "OPTIONS": self = .options
        case "GET": self = .get
        case "HEAD": self = .head
        case "POST": self = .post
        case "PUT": self = .put
        case "PATCH": self = .patch
        case "DELETE": self = .delete
        case "TRACE": self = .trace
        case "CONNECT": self = .connect
        default: return nil
        }
    }
    fileprivate var rawString: String {
        switch self {
        case .options: return "OPTIONS"
        case .get: return "GET"
        case .head: return "HEAD"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .trace: return "TRACE"
        case .connect: return "CONNECT"
        }
    }
}

extension URLRequest {
    public init?(method: HTTPMethod, url: String, parameters: [String: Any]?) {
        guard let parameters = parameters else {
            self.init(method: method.rawString, url: url, body: nil)
            return
        }
        switch method {
        case .get, .head, .delete:
            if parameters.isEmpty == false,
                let u = URL(string: url),
                var components = URLComponents(url: u, resolvingAgainstBaseURL: false) {
                let encodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + URLRequest.query(parameters)
                components.percentEncodedQuery = encodedQuery
                if let encodeUrl = components.url?.absoluteString {
                    self.init(method: method.rawString, url: encodeUrl, body: nil)
                    return
                }
            }
            self.init(method: method.rawString, url: url, body: nil)
        case .post:
            let body: Data?
            do {
                body = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch let error {
                debugPrint(error.localizedDescription, parameters.debugDescription)
                body = URLRequest.query(parameters).data(using: .utf8, allowLossyConversion: false)
            }
            self.init(method: method.rawString, url: url, body: body)
        default:
            self.init(method: method.rawString, url: url, body: nil)
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
            // Content-Type and Accept below
            // Content-Type will be set automatic
            // "application/x-www-form-urlencoded", "charset=utf-8", "multipart/form-data", "application/json", "text/xml"
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
    private static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
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
    private static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
