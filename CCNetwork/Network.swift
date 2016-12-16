//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

open class Network: NSObject {
    
    open static let instance = Network()
    open var session:URLSession
    open var completeQueue:DispatchQueue = DispatchQueue.main
    open var downloadDirectory:URL?
    
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
        if #available(iOS 8.0, *) {
            config.sharedContainerIdentifier = "CCNetwork"
        } else {
            // Fallback on earlier versions
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
        config.httpAdditionalHeaders = ["Accept": "application/json"] //text/html
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
        
        do {
            self.downloadDirectory =  try FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        } catch {
            if let urlStr = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first,
                let url = URL(string: urlStr) {
                self.downloadDirectory = url
            } else {
                // self.downloadDirectory will be nil
            }
        }
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
    
    final func dataTask(request:URLRequest, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDataTask {
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
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
        task.resume()
        return task
    }
    
    final func downloadTask(url:URL, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        let task = self.session.downloadTask(with: url) { (url, response, error) in
            guard let url = url else {
                if let error = error {
                    fail(error)
                } else {
                    fail(NSError(domain: "some catch path error", code: -1, userInfo: nil) as Error)
                }
                return
            }
            
            do {
                //try FileManager.default.moveItem(at: url, to: destinationUrl)
                let data = try Data(contentsOf: url)
                success(data)
            } catch let error {
                fail(error)
            }
            
            /*
             guard let url = url,
             let dir = self?.downloadDirectory,
             let filename = request.url?.lastPathComponent else {
             if let error = error {
             fail(error)
             } else {
             fail(NSError(domain: "some catch path error", code: -1, userInfo: nil) as Error)
             }
             return
             }
             
             let destinationUrl = dir.appendingPathComponent(filename)
             var data:Data?
             do {
             try FileManager.default.moveItem(at: url, to: destinationUrl)
             data = try Data(contentsOf: destinationUrl)
             } catch let error {
             fail(error)
             }
             if let data = data {
             success(data)
             } else {
             print("some error")
             }
             */
        }
        task.resume()
        return task
    }
    
    
}



