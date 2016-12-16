//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation

extension Network {
    
    // MARK: - Request
    open class func request(url:String, method:String, parameter:Dictionary<String, Any>?, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.instance.request(httpMethod: method, url: url, parameter: (parameter as NSDictionary?)?.jsonData) else {
            fail(NSError(domain: "generate request", code: -1, userInfo: ["url" : url]) as Error)
            return nil
        }
        return Network.instance.dataTask(request: request as URLRequest, success: success, fail: fail)
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
    open class func download(url:String, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        guard let url = URL(string: url) else {
            fail(NSError(domain: "invalid url", code: -1, userInfo: nil) as Error)
            return nil
        }
        return Network.instance.downloadTask(url: url, success: success, fail: fail)
    }
}
