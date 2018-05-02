//  Created by Songwen Ding on 2017/8/16.
//  Copyright © 2017年 DingSoung. All rights reserved.

import Foundation

// copy from Extension Swift+Association.swift
fileprivate final class Association<T: Any> {
    private let policy: objc_AssociationPolicy
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }
    public subscript(index: Any) -> T? {
        get {return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T}
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

@objc
extension Network {
    @nonobjc private static let association = Association<OperationQueue>()
    /// default main queue
    open class var completeQueue: OperationQueue {
        get {return Network.association[self] ?? OperationQueue.main}
        set {Network.association[self] = newValue}
    }
}
