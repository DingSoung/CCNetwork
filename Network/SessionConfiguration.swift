//  Created by Songwen Ding on 10/12/17.
//  Copyright © 2017 DingSoung. All rights reserved.

import Foundation

@objcMembers
public class SessionConfiguration: URLSessionConfiguration {
    override init() {
        super.init()

        self.requestCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
        self.timeoutIntervalForRequest = 60.0;
        self.timeoutIntervalForResource = 60 * 60 * 24 * 7;
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
        self.httpAdditionalHeaders = ["Accept": "application/json"] //text/html
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
