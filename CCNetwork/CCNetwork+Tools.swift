//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

extension CCNetwork {
    
    fileprivate enum httpMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    /// POST request
    public class func post(url:String, parameter:NSDictionary, success: @escaping ((_ data: Data) -> Void), fail: @escaping ((_ error: Error) -> Void)) -> URLSessionDataTask? {
        let parameter = NSKeyedArchiver.archivedData(withRootObject: parameter)
        guard let request = CCNetwork.instance.generateRequest(httpMethod: self.httpMethod.post.rawValue, url: url, parameter: parameter as NSData?) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url, "parameter": parameter]))
            return nil
        }
        return CCNetwork.instance.processTask(request: request as URLRequest, success: success, fail: fail)
    }
    
    /// GET request
    public class func get(url:String, parameter:NSDictionary?, success:@escaping ((_ data: Data) -> Void), fail:@escaping ((_ error: Error) -> Void)) -> URLSessionDataTask? {
        guard let request = CCNetwork.instance.generateRequest(httpMethod: self.httpMethod.get.rawValue, url: url, parameter: nil) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url]))
            return nil
        }
        return CCNetwork.instance.processTask(request: request as URLRequest, success: success, fail: fail)
    }
}
