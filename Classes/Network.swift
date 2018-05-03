//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

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

@objcMembers public final class Network: NSObject {
    public static let shared = Network()
    fileprivate override init() {}
    deinit {}

    public lazy var completionQueue: OperationQueue = {
        return OperationQueue.main
    }()
    open lazy var sessionConfiguration: URLSessionConfiguration = {
        return URLSessionConfiguration(timeout: 60, httpHeaders: ["Accept": "application/json"])
    }()
    public weak var sessionDelegate = NetworkSessionDelegate()
    public lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration, delegate: self.sessionDelegate, delegateQueue: self.completionQueue)
    }()
}

extension Network {
    // TODO: create functiuon to generate request, manage request
    public class func json<T>(request: URLRequest,
                              queue: OperationQueue = Network.shared.completionQueue,
                              trasnform: @escaping ([String: Any]) -> T?,
                              completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        return request.dataTask(session: Network.shared.session, completion: { (obj, _, error) in
            if let dict = obj as? [String: Any], let json = trasnform(dict) {
                queue.addOperation { completion(json, nil) }
            } else {
                queue.addOperation { completion(nil, error ?? NetworkError(code: -2, message: "phrase json fail")) }
            }
        })
    }
}
