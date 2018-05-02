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
        #if os(OSX)
        if #available(OSX 10.10, *) {
            self.isDiscretionary = true
            self.sharedContainerIdentifier = "Network"
        }
        #else
        self.isDiscretionary = true
        self.sharedContainerIdentifier = "Network"
        #endif
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
        #if os(iOS)
        if #available(iOS 9.0, *) { self.shouldUseExtendedBackgroundIdleMode = true }
        #elseif os(OSX)
        if #available(OSX 10.11, *) { self.shouldUseExtendedBackgroundIdleMode = true }
        #else
        self.shouldUseExtendedBackgroundIdleMode = true
        #endif
        self.protocolClasses = []
    }
}
