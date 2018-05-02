//  Created by Songwen Ding on 2016/12/7.
//  Copyright © 2016年 DingSoung. All rights reserved.

import Foundation
import SystemConfiguration

public enum NetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}

extension SCNetworkReachability {
    public static let notification = "NetworkReachabilityChangedNotification"

    public class func reachability(hostName: String) -> SCNetworkReachability? {
        return SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, hostName)
    }
    public class func reachability(hostAddress: inout sockaddr) -> SCNetworkReachability? {
        return SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &hostAddress)
    }
    public class var reachabilityForInternetConnection: SCNetworkReachability? {
        var zeroAddress: sockaddr?
        let size = MemoryLayout<sockaddr>.size
        bzero(&zeroAddress, size)
        zeroAddress?.sa_len = __uint8_t(size)
        zeroAddress?.sa_family = sa_family_t(AF_INET)
        guard var za = zeroAddress else { return nil }
        return reachability(hostAddress: &za)
    }

    @discardableResult public func startNotifier() -> Bool {
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        let callback: SCNetworkReachabilityCallBack = { _, _, info in
            guard let info  = info else { return }
            let networkReachability = Unmanaged<SCNetworkReachability>.fromOpaque(info).takeUnretainedValue() as SCNetworkReachability
            NotificationCenter.default.post(name: Notification.Name(rawValue: SCNetworkReachability.notification), object: networkReachability)
        }
        return SCNetworkReachabilitySetCallback(self, callback, &context)
            && SCNetworkReachabilityScheduleWithRunLoop(self, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }

    public func stopNotifier() {
        SCNetworkReachabilityUnscheduleFromRunLoop(self, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}

extension SCNetworkReachability {
    func networkStatus(flags: SCNetworkReachabilityFlags) -> NetworkStatus {
        guard flags.contains(.reachable) else { return .notReachable }
        var ret: NetworkStatus = .notReachable
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
    public var connectionRequired: Bool {
        var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(self, &flags)
        return flags.contains(.connectionRequired)
    }
    var currentReachabilityStatus: NetworkStatus {
        var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(self, &flags)
        return self.networkStatus(flags: flags)
    }
}
