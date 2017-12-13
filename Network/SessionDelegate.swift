//  Created by Songwen Ding on 2017/9/19.
//  Copyright © 2017年 DingSoung. All rights reserved.

import Foundation

@objcMembers
public class SessionDelegate: NSObject, URLSessionDelegate {
    @objc open var SSLPinning: Data?

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

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

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}
