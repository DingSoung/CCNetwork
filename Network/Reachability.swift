//  Created by Songwen Ding on 2016/12/7.
//  Copyright © 2016年 DingSoung. All rights reserved.

import Foundation

import SystemConfiguration


/*
 @objc enum ReachabilityStatus:Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}
*/

@objc open class Reachability:NSObject {
    
    public static let changedNotification = "kNetworkReachabilityChangedNotification"
    
    private var networkReachability:SCNetworkReachability?
    private var notifying: Bool = false
    
    public init?(hostName: String) {
        networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, hostName)
        
        super.init()
        if networkReachability == nil {
            return nil
        }
    }
    
    public init?(ipAddress: sockaddr_in) {
        let RouteReachability = { (ip:inout sockaddr_in) -> SCNetworkReachability? in
            guard let defaultRouteReachability = withUnsafePointer(to: &ip, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
                }
            }) else {
                return nil
            }
            return defaultRouteReachability
        }
        
        var address = ipAddress
        networkReachability = RouteReachability(&address)
        if (networkReachability != nil) {
        } else {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            networkReachability = RouteReachability(&zeroAddress)
        }
        
        super.init()
        if networkReachability == nil {
            return nil
        }
    }
    
    private override init() {
        super.init()
    }
    
    deinit {
        stopNotifier()
    }
    
    open func startNotifier() -> Bool {
        guard notifying == false else {
            return false
        }
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard let reachability = networkReachability,
            SCNetworkReachabilitySetCallback(reachability, { (target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            if let currentInfo = info {
                let infoObject = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue()
                if infoObject is Reachability {
                    let networkReachability = infoObject as! Reachability
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Reachability.changedNotification), object: networkReachability)
                }
            }
        }, &context) == true else {
            return false
        }
        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else {
            return false
        }
        notifying = true
        return notifying
    }
    
    open func stopNotifier() {
        if let reachability = networkReachability, notifying == true {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode as! CFString)
            notifying = false
        }
    }
    
    open var currentReachabilityFlags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, { SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0)) }) == true {
            return flags
        }
        else {
            return []
        }
    }
    
    /*
    open var reachable:Bool {
        // The target host is not reachable.
        if (currentReachabilityFlags.contains(.reachable) == false) {
            return false;
        }
        
        // If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
        if currentReachabilityFlags.contains(.connectionRequired) == false {
            return true //Wi-Fi
        }
        
        // ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if currentReachabilityFlags.contains(.connectionOnDemand) == true || currentReachabilityFlags.contains(.connectionOnTraffic) == true {
            //... and no [user] intervention is needed...
            if currentReachabilityFlags.contains(.interventionRequired) == false {
                return true //Wi-Fi
            }
        }
        
        // ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
        if currentReachabilityFlags.contains(.isWWAN) == true {
            return true //WWAN
        }
        
        return false
    }
     */
    
    open var connectionRequired:Bool {
        guard let reach = self.networkReachability else {
            return false
        }
        var flags = SCNetworkReachabilityFlags.connectionAutomatic
        if SCNetworkReachabilityGetFlags(reach, &flags) {
            return flags.contains(.connectionRequired)
        }
        return false
    }
    
}
