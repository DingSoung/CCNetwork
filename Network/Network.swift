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
                    config.requestCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
                    config.timeoutIntervalForRequest = 60.0;
                    config.timeoutIntervalForResource = 60 * 60 * 24 * 7;
                    config.networkServiceType = NSURLRequest.NetworkServiceType.default
                    config.allowsCellularAccess = true
                    //config.isDiscretionary = true
                    if #available(iOS 8.0, *) {
                        config.sharedContainerIdentifier = "Network"
                    } else {
                        // Fallback on earlier versions
                    }
                    config.sessionSendsLaunchEvents = true
                    config.connectionProxyDictionary = nil
                    config.tlsMinimumSupportedProtocol = SSLProtocol.sslProtocol3
                    config.tlsMaximumSupportedProtocol = SSLProtocol.tlsProtocol12
                    config.httpShouldUsePipelining = false
                    config.httpShouldSetCookies = true
                    config.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
                    config.httpAdditionalHeaders = ["Accept": "application/json"] //text/html
                    config.httpMaximumConnectionsPerHost = 4
                    config.httpCookieStorage =  HTTPCookieStorage.shared
                    config.urlCredentialStorage = URLCredentialStorage.shared
                    config.urlCache = URLCache.shared
                    if #available(iOS 9.0, *) {
                        config.shouldUseExtendedBackgroundIdleMode = true
                    } else {
                        // Fallback on earlier versions
                    }
                    config.protocolClasses = []
                    return config
                }(),
                           delegate: SessionDelegateObject(),
                           delegateQueue: OperationQueue())
        )
        super.init()
    }
    deinit {
    }
    
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




