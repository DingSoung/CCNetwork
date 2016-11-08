//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

open class Network: NSObject {
    
    open static let instance = Network()
    open var session:URLSession
    
    fileprivate override init() {
        session = {
            return $0
        }(URLSession(configuration: URLSessionConfiguration.default))
        
        //configuration:
        let config = session.configuration
        config.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        config.timeoutIntervalForRequest = 30.0;
        config.timeoutIntervalForResource = 60.0;
        config.networkServiceType = NSURLRequest.NetworkServiceType.default
        config.allowsCellularAccess = true
        config.isDiscretionary = true
        if NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 {
            config.sharedContainerIdentifier = "CCNetwork"
        }
        config.sessionSendsLaunchEvents = true
        
        /*
         open var connectionProxyDictionary: [AnyHashable : Any]?
         open var tlsMinimumSupportedProtocol: SSLProtocol
         open var tlsMaximumSupportedProtocol: SSLProtocol
         open var httpShouldUsePipelining: Bool
         open var httpShouldSetCookies: Bool
         open var httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy
         */
        config.httpAdditionalHeaders = ["Accept": "application/json"] //test/html
        config.httpMaximumConnectionsPerHost = 10;
        /*
         open var httpCookieStorage: HTTPCookieStorage?
         open var urlCredentialStorage: URLCredentialStorage?
         open var urlCache: URLCache?
         @available(iOS 9.0, *)
         open var shouldUseExtendedBackgroundIdleMode: Bool
         open var protocolClasses: [Swift.AnyClass]?
         */
        
        super.init()
    }
    deinit {
    }
    
    
    // 写一个operation  queue 管理task， 方便 暂停 取消 控制并发数量 等等
    
    final func generateRequest(httpMethod:String, url:String, parameter:Data?) -> NSMutableURLRequest? {
        guard let URL = NSURL(string: url) else {
            return nil
        }
        let request = NSMutableURLRequest(url: URL as URL)
        //request.cachePolicy
        request.timeoutInterval = 12
        //request.mainDocumentURL
        //request.networkServiceType
        request.allowsCellularAccess = true
        request.httpMethod = httpMethod
        if httpMethod == "POST" {
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = parameter
        }
        //request.allHTTPHeaderFields
        //request.HTTPShouldHandleCookies
        //request.HTTPShouldUsePipelining
        /*
        request.httpMethod = "POST"
        request.httpBody = "data=Hello".data(using: String.Encoding.utf8, allowLossyConversion: true) 
         */
        return request
    }
    
    final func processDataTask(request:URLRequest, success:@escaping ((_ data:Data)->Void), fail:@escaping ((_ error:Error)->Void)) -> URLSessionDataTask {
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                success(data)
            } else {
                if let error = error {
                    fail(error)
                } else {
                    fail(NSError(domain: "request fail", code: -1, userInfo: nil))
                }
            }
        }
        task.resume()
        return task
    }
    
    final func processDownloadTask(request:URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDownloadTask {
        let task = self.session.downloadTask(with: request, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    
    
    
}




