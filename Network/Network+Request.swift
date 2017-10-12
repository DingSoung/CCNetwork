//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

@objc
extension Network {
    public final class func request(method: String, url: String, parameter: Data?) -> NSMutableURLRequest? {
        guard let URL = NSURL(string: url) else {
            return nil
        }
        let request = NSMutableURLRequest(url: URL as URL)
        //request.cachePolicy
        request.timeoutInterval = 30
        //request.mainDocumentURL
        request.networkServiceType = NSURLRequest.NetworkServiceType.default
        request.allowsCellularAccess = true
        request.httpMethod = method
        if method == "POST" {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = parameter
        }
        //request.allHTTPHeaderFields
        request.httpShouldHandleCookies = true
        request.httpShouldUsePipelining = true
        return request
    }
}
