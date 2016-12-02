//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

open class Network: NSObject {
    
    open static let instance = Network()
    open var session:URLSession
    open var completeQueue:DispatchQueue = DispatchQueue.main
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
    
    final func request(httpMethod:String, url:String, parameter:Data?) -> NSMutableURLRequest? {
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
    
    final func task(request:URLRequest, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        
        var task:URLSessionTask?
        guard let httpMethod = request.httpMethod else {return task}
        switch httpMethod {
        case "GET", "POST":
            task = self.session.dataTask(with: request) { (data, response, error) -> Void in
                self.completeQueue.sync {
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
            }
            /*
        case "DOWNLOAD":
            task = self.session.downloadTask(with: request, completionHandler: { (url, response, error) in
                
                guard let url = url else {
                
                }
                let uuid = NSUUID().UUIDString
                print(uuid)
                
                FileManager.default.moveItem(at: url, to: <#T##URL#>)
                
                
                if (fileURL) {
                    delegate.downloadFileURL = fileURL;
                    NSError *error = nil;
                    
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
                    if (error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
                    }
                    
                    return;
                }
             
                let fileManager = FileManager.default
                let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documents.URLByAppendingPathComponent("test.jpg")
                do {
                    try fileManager.moveItemAtURL(location!, toURL: fileURL)
                } catch {
                    print(error)
                }
            })
 */
        default: break
        }
        
        task?.resume()
        return task
    }
    
    
    
    
}




