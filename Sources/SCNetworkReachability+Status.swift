//  Created by Songwen Ding on 2016/12/7.
//  Copyright © 2016年 DingSoung. All rights reserved.

import Foundation
#if !os(watchOS)
import SystemConfiguration

extension SCNetworkReachability {
    /// init with host, ex:  domain.com
    public class func reachability(hostName: String) -> SCNetworkReachability? {
        return SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, hostName)
    }
    public class func reachability(hostAddress: inout sockaddr_in) -> SCNetworkReachability? {
        return withUnsafePointer(to: &hostAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        })
    }
    public class var reachabilityForInternetConnection: SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return self.reachability(hostAddress: &zeroAddress)
    }
}

extension SCNetworkReachability {
    private static var updateCallBackKey: UInt8 = 0
    /// status updated callback
    public var updateCallBack: ((SCNetworkReachability.Status) -> Void)? {
        set { objc_setAssociatedObject(self, &SCNetworkReachability.updateCallBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &SCNetworkReachability.updateCallBackKey) as? (SCNetworkReachability.Status) -> Void }
    }
}

extension SCNetworkReachability {
    /// start
    @discardableResult public func start() -> Bool {
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        let callback: SCNetworkReachabilityCallBack = { _, _, info in
            guard let info  = info else { return }
            let networkReachability = Unmanaged<SCNetworkReachability>.fromOpaque(info).takeUnretainedValue() as SCNetworkReachability
            networkReachability.updateCallBack?(networkReachability.currentReachabilityStatus)
        }
        return SCNetworkReachabilitySetCallback(self, callback, &context)
            && SCNetworkReachabilityScheduleWithRunLoop(self, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
    /// stop
    public func stop() {
        SCNetworkReachabilityUnscheduleFromRunLoop(self, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}

extension SCNetworkReachability {
    public enum Status: Int {
        case notReachable = 0
        case reachableViaWiFi
        case reachableViaWWAN
    }
    private func networkStatus(flags: SCNetworkReachabilityFlags) -> Status {
        guard flags.contains(.reachable) else { return .notReachable }
        var ret: Status = .notReachable
        if flags.contains(.connectionRequired) == false { ret = .reachableViaWiFi }
        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
            if flags.contains(.interventionRequired) == false {
                ret = .reachableViaWiFi
            }
        }
        #if os(iOS)
        if #available(iOS 9, *) {
            if flags.contains(SCNetworkReachabilityFlags.isWWAN) { ret = .reachableViaWWAN }
        }
        #endif
        return ret
    }
    public var currentReachabilityStatus: Status {
        var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(self, &flags)
        return self.networkStatus(flags: flags)
    }
}
#endif
