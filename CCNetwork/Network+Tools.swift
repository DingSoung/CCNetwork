//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

extension Network {
    
    fileprivate enum httpMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    /// POST request
    open class func post(url:String, parameter:Dictionary<String, Any>, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.instance.generateRequest(httpMethod: self.httpMethod.post.rawValue, url: url, parameter: (parameter as NSDictionary).jsonData) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url, "parameter": parameter]) as Error)
            return nil
        }
        return Network.instance.processDataTask(request: request as URLRequest, success: success, fail: fail)
    }
    
    /// GET request
    open class func get(url:String, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.instance.generateRequest(httpMethod: self.httpMethod.get.rawValue, url: url, parameter: nil) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url]) as Error)
            return nil
        }
        return Network.instance.processDataTask(request: request as URLRequest, success: success, fail: fail)
    }
    
    /// Download request
    open class func possssssst(url:String, parameter:Dictionary<String, Any>, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        guard let request = Network.instance.generateRequest(httpMethod: self.httpMethod.post.rawValue, url: url, parameter: (parameter as NSDictionary).jsonData) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url, "parameter": parameter]) as Error)
            return nil
        }
        return Network.instance.processDownloadTask(request: request as URLRequest, completionHandler: { (url, response, error) in
            
            guard url != nil && error == nil else {
                //print(error?.localizedDescription ?? "")
                return
            }
            
                       
        })
    }
    
}
