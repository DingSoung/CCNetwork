//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

private struct NetworkError: Error {
    let code: Int
    let message: String
}

extension NetworkError: LocalizedError {
    fileprivate var errorDescription: String? { return self.message }
    fileprivate var failureReason: String? { return self.message }
    fileprivate var recoverySuggestion: String? { return "Please Check" }
    fileprivate var helpAnchor: String? { return "Update to Latest version" }
}

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
        return URLSessionConfiguration(timeout: 60, httpHeaders: ["Accept": "application/json"])
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
                queue.addOperation { completion(nil, error ?? NetworkError(code: -2, message: "phrase json fail")) }
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
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        } else {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        }
    }
    #if !os(OSX)
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
    #endif
}
