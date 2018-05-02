//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import UIKit

extension URLRequest {
    public static func request(method: String = "POST", url: String, parameters: [String: Any]?) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        let request = NSMutableURLRequest(url: url)
        //request.cachePolicy
        request.timeoutInterval = 30
        //request.mainDocumentURL
        request.networkServiceType = URLRequest.NetworkServiceType.default
        request.allowsCellularAccess = true
        request.httpMethod = method
        [
            "application/x-www-form-urlencoded; charset=utf-8": "Content-Type",
            //"multipart/form-data": "Content-Type",
            //"application/json": "Content-Type",
            //"text/xml": "Content-Type",
            //"charset=utf-8": "Content-Type",
            "*/*": "Accept"
            ].forEach { (key, value) in
                request.addValue(key, forHTTPHeaderField: value)
        }
        if method == "POST", let parameters = parameters {
            request.httpBody = query(parameters).data(using: String.Encoding.utf8, allowLossyConversion: false)
        }
        request.httpShouldHandleCookies = true
        request.httpShouldUsePipelining = true
        return request as URLRequest
    }
}

// MARK: - copy from alamofire
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

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
