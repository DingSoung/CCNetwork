//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

@objcMembers public final class Network: NSObject {
    public static let shared = Network()
    fileprivate override init() {}
    deinit {}

    public lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration,
                          delegate: SessionDelegate(),
                          delegateQueue: self.completionQueue)
    }()
    public var sslPinning: Data? {
        set { (self.session.delegate as? SessionDelegate)?.sslPinning = newValue }
        get { return (self.session.delegate as? SessionDelegate)?.sslPinning }
    }
    public lazy var completionQueue: OperationQueue = {
        return OperationQueue.main
    }()
    public lazy var sessionConfiguration: URLSessionConfiguration = {
        return URLSessionConfiguration.configuration(timeout: 60,
                                                     httpHeaders: ["Accept-Language": Locale.preferredLanguages.first ?? Locale.current.identifier])
    }()
}

extension Network {
    @discardableResult public class func json<T>(request: URLRequest,
                                                 queue: OperationQueue = Network.shared.completionQueue,
                                                 trasnform: @escaping ([String: Any]) -> T?,
                                                 completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        return request.dataTask(session: Network.shared.session, completion: { (obj, _, error) in
            if let dict = obj as? [String: Any], let json = trasnform(dict) {
                queue.addOperation { completion(json, nil) }
            } else {
                queue.addOperation { completion(nil, error ?? NetworkError(code: .notJSON)) }
            }
        })
    }
}

extension Network {
    private class SessionDelegate: NSObject, URLSessionDelegate {
        var sslPinning: Data?
        /// MARK: URLSessionDelegate
        func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                return
            }
            if let localCert = sslPinning, let secCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
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
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            } else {
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
        }
        #if !os(OSX)
        func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
        #endif
    }
}
