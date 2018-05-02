//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

@objc extension Network {
    @objc public enum HTTPMethod: Int {
        case options = 0, get, head, post, put, patch, delete, trace, connect
    }
}

extension Network.HTTPMethod {
    public var rawString: String {
        switch self {
        case .options:
            return "OPTIONS"
        case .get:
            return "GET"
        case .head:
            return "HEAD"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        case .trace:
            return "TRACE"
        case .connect:
            return "connect"
        }
    }
}
