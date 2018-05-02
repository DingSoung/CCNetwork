//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

extension URLSessionConfiguration {
    public convenience init(timeout: TimeInterval, httpHeaders: [AnyHashable: Any]?) {
        self.init()
        self.requestCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
        self.timeoutIntervalForRequest = timeout
        self.timeoutIntervalForResource = timeout * 60 * 24 * 7
        self.networkServiceType = NSURLRequest.NetworkServiceType.default
        self.allowsCellularAccess = true
        //config.isDiscretionary = true
        if #available(iOS 8.0, *) {
            self.sharedContainerIdentifier = "Network"
        } else {
            // Fallback on earlier versions
        }
        self.sessionSendsLaunchEvents = true
        self.connectionProxyDictionary = nil
        self.tlsMinimumSupportedProtocol = SSLProtocol.sslProtocol3
        self.tlsMaximumSupportedProtocol = SSLProtocol.tlsProtocol12
        self.httpShouldUsePipelining = false
        self.httpShouldSetCookies = true
        self.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
        self.httpAdditionalHeaders = httpHeaders
        self.httpMaximumConnectionsPerHost = 4
        self.httpCookieStorage =  HTTPCookieStorage.shared
        self.urlCredentialStorage = URLCredentialStorage.shared
        self.urlCache = URLCache.shared
        if #available(iOS 9.0, *) {
            self.shouldUseExtendedBackgroundIdleMode = true
        } else {
            // Fallback on earlier versions
        }
        self.protocolClasses = []
    }
}
