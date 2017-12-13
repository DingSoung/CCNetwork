//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

extension Dictionary {
    /// Dictionary -> JSON Data
    fileprivate var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let error as NSError {
            print("format \(String(describing: self)) to Data fail:\(error.domain)")
            return nil
        }
    }
}

@objc
extension Network {

    fileprivate enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }

    /// POST
    @discardableResult open class func post(session: URLSession,
                                            url: String,
                                            parameter: [String: Any],
                                            success: @escaping ((Data) -> Swift.Void),
                                            fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        return Network.data(session: session, url: url, method: HTTPMethod.post.rawValue, parameter: parameter.jsonData, success: success, fail: fail)
    }
    /// GET
    @discardableResult open class func get(session: URLSession,
                                           url: String,
                                           success: @escaping ((Data) -> Swift.Void),
                                           fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        return Network.data(session: session, url: url, method: HTTPMethod.get.rawValue, parameter: nil, success: success, fail: fail)
    }
}
