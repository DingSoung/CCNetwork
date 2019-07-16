//  Created by Songwen Ding on 2018/6/5.
//  Copyright © 2018年 DingSoung. All rights reserved.

import Foundation

@objc public enum HTTPMethod: Int {
    case get = 0, head, delete, post
}

extension HTTPMethod {
    public init?(rawString: String) {
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

    public var rawString: String {
        switch self {
        case .get: return "GET"
        case .head: return "HEAD"
        case .delete: return "DELETE"
        case .post: return "POST"
        }
    }
}
