//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation
import Extension

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
    @discardableResult open class func post(url:String, parameter:Dictionary<String, Any>, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        return Network.data(url: url, method: HTTPMethod.post.rawValue, parameter: parameter, success: success, fail: fail)
    }
    /// GET
    @discardableResult open class func get(url:String, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        return Network.data(url: url, method: HTTPMethod.get.rawValue, parameter: nil, success: success, fail: fail)
    }
}
