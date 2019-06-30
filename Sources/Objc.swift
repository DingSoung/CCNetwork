//  Created by Songwen Ding on 2018/5/3.
//  Copyright © 2018年 DingSoung. All rights reserved.

import Foundation

extension Network {
    @discardableResult public class func json(request: URLRequest,
                                              trasnform: @escaping ([String: Any]) -> Any?,
                                              completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
        return Network.json(request: request, queue: .main, trasnform: trasnform, completion: completion)
    }
}

extension NSURLRequest {
    @objc public class func request(method: HTTPMethod, url: URL, parameters: [String: Any]?) -> NSURLRequest? {
        guard let m = HTTPMethod(rawValue: method.rawValue) else { return nil }
        return URLRequest(method: m, url: url, parameters: parameters) as NSURLRequest?
    }
}

extension NSURLRequest {
    @objc @discardableResult public func dataTask(session: URLSession?,
                                                  completion: @escaping ((Any?, URLResponse?, Error?) -> Void)) -> URLSessionDataTask {
        return (self as URLRequest).dataTask(session: session ?? .shared, completion: completion)
    }
}

extension NSURLRequest {
    @objc @discardableResult public func downloadTask(session: URLSession?,
                                                      completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> URLSessionDownloadTask {
        return (self as URLRequest).downloadTask(session: session ?? .shared, completion: completion)
    }
}
