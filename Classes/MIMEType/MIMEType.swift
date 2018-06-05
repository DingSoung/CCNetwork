//  Created by Songwen Ding on 2018/6/5.
//  Copyright © 2018年 DingSoung. All rights reserved.

import Foundation

@objc public enum MIMEType: Int {
    case wwwFormUrlEncoded = 0, json
}

// MARK: - MIMEType
extension MIMEType {
    init?(raw: String) {
        if raw.hasPrefix(MIMEType.wwwFormUrlEncoded.raw) { self = .wwwFormUrlEncoded; return }
        if raw.hasPrefix(MIMEType.json.raw) { self = .json; return }
        return nil
    }
    var raw: String {
        switch self {
        case .wwwFormUrlEncoded: return "application/x-www-form-urlencoded"
        case .json: return "application/json"
        }
        // unsupport type "charset=utf-8", "multipart/form-data", "text/xml"
    }
}
