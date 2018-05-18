//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

// MARK: - HTTPMethod
extension URLRequest {
    public enum HTTPMethod: Int {
        case get = 0, head, delete, post
    }
}

extension URLRequest.HTTPMethod {
    init?(raw: String) {
        switch raw {
        case "GET": self = .get
        case "HEAD": self = .head
        case "DELETE": self = .delete
        case "POST": self = .post
        default:
            // unsupport type: "OPTIONS" "PUT" "PATCH" "TRACE" "CONNECT"
            return nil
        }
    }
    var raw: String {
        switch self {
        case .get: return "GET"
        case .head: return "HEAD"
        case .delete: return "DELETE"
        case .post: return "POST"
        }
    }
}

extension URLRequest {
    public enum MIMEType: Int {
        case www_form_urlencoded = 0, json
    }
}

// MARK: - MIMEType
extension URLRequest.MIMEType {
    init?(raw: String) {
        if raw.hasPrefix(URLRequest.MIMEType.www_form_urlencoded.raw) { self = .www_form_urlencoded; return }
        if raw.hasPrefix(URLRequest.MIMEType.json.raw) { self = .json; return }
        return nil
    }
    var raw: String {
        switch self {
        case .www_form_urlencoded: return "application/x-www-form-urlencoded"
        case .json: return "application/json"
        }
        // unsupport type "charset=utf-8", "multipart/form-data", "text/xml"
    }
}

// MARK: MIME transform for Content-Type Dictionary
extension Dictionary where Key == String {
    public var json: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self)
        } catch let error {
            debugPrint(error.localizedDescription, self.debugDescription)
            return nil
        }
    }
    public var www_form_urlencoded: String {
        var components: [(String, String)] = []
        for key in self.keys.sorted(by: <) {
            let value = self[key]!
            components += String.queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

extension Dictionary where Key == String {
    public var jsonString: String? {
        guard let data = self.json else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: Others Base trasnform
extension Data {
    public var jsonObject: Any? {
        do {
            return try  JSONSerialization.jsonObject(with: self)
        } catch let error {
            debugPrint(error.localizedDescription, self.debugDescription)
            return nil
        }
    }
}

extension Data {
    public var jsonArray: [Any]? {
        return self.jsonObject as? Array
    }
    public var jsonDictionary: [String: Any]? {
        return self.jsonObject as? [String: Any]
    }
}

// MARK: - for url encoded
extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension String {
    fileprivate var escape: String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        var escaped = ""
        if #available(iOS 8.3, *) {
            escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
        } else {
            let batchSize = 50
            var index = self.startIndex
            while index != self.endIndex {
                let startIndex = index
                let endIndex = self.index(index, offsetBy: batchSize, limitedBy: self.endIndex) ?? self.endIndex
                let range = startIndex..<endIndex
                let substring = self[range]
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                index = endIndex
            }
        }
        return escaped
    }
    fileprivate static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
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
                components.append((key.escape, (value.boolValue ? "1" : "0").escape))
            } else {
                components.append((key.escape, "\(value)".escape))
            }
        } else if let bool = value as? Bool {
            components.append((key.escape, (bool ? "1" : "0").escape))
        } else {
            components.append((key.escape, "\(value)".escape))
        }
        return components
    }
}
