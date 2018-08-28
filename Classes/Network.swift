//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

@objcMembers public final class Network: NSObject {
    public static let shared = Network()
    fileprivate override init() {}
    deinit {}

    public lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: self.completionQueue)
    }()
    open var sslPinning: Data?
    public lazy var completionQueue: OperationQueue = {
        return OperationQueue.main
    }()
    open lazy var sessionConfiguration: URLSessionConfiguration = {
        return URLSessionConfiguration.configuration(timeout: 60,
                                                     httpHeaders: ["Accept-Language": Locale.preferredLanguages.first ?? Locale.current.identifier])
    }()
}

extension Network {
    // TODO: create functiuon to generate request, manage request
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

extension Network: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            return
        }
        if let localCert = self.sslPinning, let secCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
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
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
    #endif
}
