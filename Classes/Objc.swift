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
    @objc public enum HTTPMethod: Int {
        case options = 0, get, head, post, put, patch, delete, trace, connect
    }
}

extension NSURLRequest.HTTPMethod {
    fileprivate var rawString: String {
        switch self {
        case .options:
            return "OPTIONS"
        case .get:
            return "GET"
        case .head:
            return "HEAD"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        case .trace:
            return "TRACE"
        case .connect:
            return "connect"
        }
    }
}

extension NSURLRequest {
    @objc public class func request(method: HTTPMethod, url: String, parameters: [String: Any]?) -> NSURLRequest? {
        guard let m = URLRequest.HTTPMethod(rawValue: method.rawValue) else { return nil }
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
