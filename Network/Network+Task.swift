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
        
    // MARK: - Data Task
    @discardableResult open class func data(session:URLSession,
                                            url: String,
                                            method: String,
                                            parameter: Data?,
                                            success: @escaping ((Data) -> Swift.Void),
                                            fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.request(method: method, url: url, parameter: parameter) as URLRequest? else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "generate request fail", code: -1, userInfo: ["url" : url]) as Error)
            }
            return nil
        }
        let task  = session.dataTask(with: request) { (data, response, error) in
            Network.completeQueue.addOperation {
                if let data = data {
                    success(data)
                } else {
                    fail(error ?? NSError(domain: "unkonw response dara", code: -1, userInfo: nil) as Error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Download Task
    @discardableResult open class func download(session:URLSession,
                                                url:String,
                                                success: @escaping ((Data) -> Swift.Void),
                                                fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        guard var request = Network.request(method: "GET", url: url, parameter: nil) as URLRequest? else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "generate request fail", code: -1, userInfo: ["url" : url]) as Error)
            }
            return nil
        }
        request.allowsCellularAccess  = false
        let task = session.downloadTask(with: request) { (url, response, error) in
            Network.completeQueue.addOperation {
                guard let url = url else {
                    fail(error ?? NSError(domain: "unkonw url of response resource error", code: -1, userInfo: nil) as Error)
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    success(data)
                } catch let error {
                    fail(error)
                }
            }
        }
        task.resume()
        return task
    }
    
}
