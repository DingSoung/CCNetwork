//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

@objc extension Network {
    @objc public enum HTTPMethod: Int {
        case options = 0, get, head, post, put, patch, delete, trace, connect
    }
}

extension Network.HTTPMethod {
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

private struct NetworkError: Error {
    let code: Int
    let message: String
}

extension NetworkError: LocalizedError {
    fileprivate var errorDescription: String? { return self.message }
    fileprivate var failureReason: String? { return self.message }
    fileprivate var recoverySuggestion: String? { return "Please Check" }
    fileprivate var helpAnchor: String? { return "Update to Latest version" }
}

@objcMembers public final class Network {
    static let shared = Network()
    fileprivate init() {}
    deinit {}

    public lazy var completionQueue: OperationQueue = {
        return OperationQueue.main
    }()
    public lazy var sessionConfiguration: URLSessionConfiguration = {
        return URLSessionConfiguration(timeout: 60, httpHeaders: ["Accept": "application/json"])
    }()
    public weak var sessionDelegate = SessionDelegate()
    public lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration, delegate: self.sessionDelegate, delegateQueue: self.completionQueue)
    }()
}

extension Network {
    // TODO: create functiuon to generate request, update request, manager request, progress response
    // TDOD: complete reach ability
    public class func json<T>(_ method: HTTPMethod, url: String, parameters: [String: Any]?,
                              updateRequest: ((inout URLRequest) -> Void)?,
                              completionQueue: OperationQueue?,
                              trasnform: @escaping ([String: Any]) -> T?,
                              completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        guard var request = URLRequest(method: method.rawString, url: url, parameters: parameters) else {
            (completionQueue ?? Network.shared.completionQueue).addOperation {
                completion(nil, NetworkError(code: -1, message: "generate request fail"))
            }
            return nil
        }
        updateRequest?(&request)
        return request.dataTask(session: Network.shared.session, completion: { (obj, _, error) in
            if let dict = obj as? [String: Any], let json = trasnform(dict) {
                (completionQueue ?? Network.shared.completionQueue).addOperation {
                    completion(json, nil)
                }
            } else {
                (completionQueue ?? Network.shared.completionQueue).addOperation {
                    completion(nil, error ?? NetworkError(code: -2, message: "phrase json fail"))
                }
            }
        })
    }
}
