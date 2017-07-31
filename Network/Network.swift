//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

@objc open class Network: NSObject {
    
    open static let instance = Network()
    open var session:URLSession
    open var sessionDelegate:SessionDelegateObject? {
        return self.session.delegate as? Network.SessionDelegateObject
    }
    @objc open class SessionDelegateObject:NSObject, URLSessionDelegate {
        open var SSLPinning:Data?
        
        public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
            
        }
        
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                return
            }
            if let localCert = self.SSLPinning, let secCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                // Set SSL policies for domain name check
                SecTrustSetPolicies(serverTrust, SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
                
                // get Evaluate server certificate result
                var secresult = SecTrustResultType.invalid
                SecTrustEvaluate(serverTrust, &secresult)
                
                // Get remote cert data
                let cFData = SecCertificateCopyData(secCertificate)
                let cert = NSData(bytes: CFDataGetBytePtr(cFData), length: CFDataGetLength(cFData))
                
                // check
                if errSecSuccess == SecTrustEvaluate(serverTrust, &secresult), cert.isEqual(to: localCert) {
                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                } else {
                    completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                }
            } else {
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                } else {
                    completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                }
            }
        }
        
        public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            
        }
    }
    
    fileprivate override init() {
        self.session = {
            return $0
            }(
                URLSession(configuration: {
                    let config = URLSessionConfiguration.default
                    config.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                    config.timeoutIntervalForRequest = 30.0;
                    config.timeoutIntervalForResource = 60.0;
                    config.networkServiceType = NSURLRequest.NetworkServiceType.default
                    config.allowsCellularAccess = true
                    config.isDiscretionary = true
                    if #available(iOS 8.0, *) {
                        config.sharedContainerIdentifier = "Network"
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
                    return config
                }(),
                           delegate: SessionDelegateObject(),
                           delegateQueue: OperationQueue())
        )
        super.init()
    }
    deinit {
    }
    
    final class func request(httpMethod:String, url:String, parameter:Data?) -> NSMutableURLRequest? {
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
        //request.httpShouldHandleCookies = true
        //request.httpShouldUsePipelining = true
        /*
         request.httpMethod = "POST"
         request.httpBody = "data=Hello".data(using: String.Encoding.utf8, allowLossyConversion: true)
         */
        return request
    }
    
    final func dataTask(request:URLRequest, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDataTask {
        let task = self.session.dataTask(with: request) {(data, response, error) -> Void in
            if let data = data {
                success(data)
            } else {
                fail(error ?? NSError(domain: "unkonw request error", code: -1, userInfo: nil) as Error)
            }
        }
        task.resume()
        return task
    }
    
    final func downloadTask(url:URL, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        let task = self.session.downloadTask(with: url) {(url, response, error) in
            guard let url = url else {
                fail(error ?? NSError(domain: "unkonw request error", code: -1, userInfo: nil) as Error)
                return
            }
            do {
                let data = try Data(contentsOf: url)
                success(data)
            } catch let error {
                fail(error)
            }
        }
        task.resume()
        return task
    }
}




