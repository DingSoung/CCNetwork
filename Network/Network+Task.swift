//  Created by Songwen Ding on 2017/8/16.
//  Copyright © 2017年 DingSoung. All rights reserved.

import Foundation

// copy from Extension Swift+Association.swift
fileprivate final class Association<T: Any> {

    private let policy: objc_AssociationPolicy

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {

        self.policy = policy
    }

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: Any) -> T? {
        get {return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T}
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

extension Dictionary {

    /// Dictionary -> JSON Data
    fileprivate var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let error as NSError {
            print("format \(String(describing: self)) to Data fail:\(error.domain)")
            return nil
        }
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
    @discardableResult open class func data(url: String, method: String, parameter: Dictionary<String, Any>?, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.request(method: method, url: url, parameter: parameter?.jsonData) as URLRequest? else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "generate request fail", code: -1, userInfo: ["url" : url]) as Error)
            }
            return nil
        }
        let task  = Network.instance.session.dataTask(with: request) { (data, response, error) in
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
    @discardableResult open class func download(url:String, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        guard var request = Network.request(method: "GET", url: url, parameter: nil) as URLRequest? else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "generate request fail", code: -1, userInfo: ["url" : url]) as Error)
            }
            return nil
        }
        request.allowsCellularAccess  = false
        let task = Network.instance.session.downloadTask(with: request) { (url, response, error) in
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
