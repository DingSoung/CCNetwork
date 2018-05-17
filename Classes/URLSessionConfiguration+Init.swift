//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

@objc extension URLSessionConfiguration {
    public class func configuration(timeout: TimeInterval, httpHeaders: [AnyHashable: Any]?) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 60 * 24 * 7
        config.networkServiceType = .default
        config.allowsCellularAccess = true
        #if os(OSX)
        if #available(OSX 10.10, *) {
            config.isDiscretionary = true
            config.sharedContainerIdentifier = "Network"
        }
        #else
        config.isDiscretionary = true
        config.sharedContainerIdentifier = "Network"
        #endif
        config.connectionProxyDictionary = nil
        config.tlsMinimumSupportedProtocol = .sslProtocol3
        config.tlsMaximumSupportedProtocol = .tlsProtocol12
        config.httpShouldUsePipelining = false
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain
        config.httpAdditionalHeaders = httpHeaders
        config.httpMaximumConnectionsPerHost = 4
        config.httpCookieStorage =  .shared
        config.urlCredentialStorage = .shared
        config.urlCache = URLCache.shared
        #if os(iOS)
        if #available(iOS 9.0, *) { config.shouldUseExtendedBackgroundIdleMode = true }
        #elseif os(OSX)
        if #available(OSX 10.11, *) { config.shouldUseExtendedBackgroundIdleMode = true }
        #else
        config.shouldUseExtendedBackgroundIdleMode = true
        #endif
        config.protocolClasses = []
        return config
    }
}
