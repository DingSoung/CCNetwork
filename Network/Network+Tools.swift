//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.

import Foundation
import Extension

extension Network {
    
    private static let association = Association<OperationQueue>()
    /// default main queue
    open class var completeQueue: OperationQueue {
        get {return Network.association[self] ?? OperationQueue.main}
        set {Network.association[self] = newValue}
    }
    
    // MARK: - Request
    @discardableResult open class func request(url:String, method:String, parameter:Dictionary<String, Any>?, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDataTask? {
        guard let request = Network.request(httpMethod: method, url: url, parameter: (parameter as NSDictionary?)?.jsonData) as URLRequest? else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "generate request fail", code: -1, userInfo: ["url" : url]) as Error)
            }
            return nil
        }
        return Network.instance.dataTask(request: request, completion: { (data, response, error) in
            Network.completeQueue.addOperation {
                if let data = data {
                    success(data)
                } else {
                    fail(error ?? NSError(domain: "unkonw response dara", code: -1, userInfo: nil) as Error)
                }
            }
        })
    }
    
    public enum httpMethod: String {
        case post = "POST"
        case get = "GET"
    }
    /// POST
    @discardableResult open class func post(url:String, parameter:Dictionary<String, Any>, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        return Network.request(url: url, method: httpMethod.post.rawValue, parameter: parameter, success: success, fail: fail)
    }
    /// GET
    @discardableResult open class func get(url:String, success:@escaping ((Data) -> Swift.Void), fail:@escaping ((Error) -> Swift.Void)) -> URLSessionTask? {
        return Network.request(url: url, method: httpMethod.get.rawValue, parameter: nil, success: success, fail: fail)
    }
    
    // MARK: - Download
    /// Download
    @discardableResult open class func download(url:String, success: @escaping ((Data) -> Swift.Void), fail: @escaping ((Error) -> Swift.Void)) -> URLSessionDownloadTask? {
        guard let url = URL(string: url) else {
            Network.completeQueue.addOperation {
                fail(NSError(domain: "invalid url", code: -1, userInfo: nil) as Error)
            }
            return nil
        }
        return Network.instance.downloadTask(url: url, completion: { (url, response, error) in
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
        })
    }
}
