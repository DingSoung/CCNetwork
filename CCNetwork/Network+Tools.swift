//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

extension Network {
    
    // MARK: - Request
    open class func request(url:String, method:String, parameter:Dictionary<String, Any>?, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        guard let request = Network.instance.request(httpMethod: method, url: url, parameter: (parameter as NSDictionary?)?.jsonData) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url]) as Error)
            return nil
        }
        return Network.instance.task(request: request as URLRequest, success: success, fail: fail)
    }
    
    public enum httpMethod: String {
        case post = "POST"
        case get = "GET"
    }
    /// POST
    open class func post(url:String, parameter:Dictionary<String, Any>, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        return Network .request(url: url, method: httpMethod.post.rawValue, parameter: parameter, success: success, fail: fail)
    }
    /// GET
    open class func get(url:String, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        return Network .request(url: url, method: httpMethod.get.rawValue, parameter: nil, success: success, fail: fail)
    }
    
    
    // MARK: - Download
    /*
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
    */
}
