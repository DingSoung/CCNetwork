//
//  URLRequest+downloadTask.swift
//  Network
//
//  Created by Songwen Ding on 2018/5/2.
//  Copyright © 2018年 DingSoung. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Download Task
    @discardableResult public func downloadTask(session: URLSession = .shared,
                                                completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: self) { (url, response, error) in
            guard let url = url else {
                completion(nil, response, error)
                return
            }
            do {
                let data = try Data(contentsOf: url)
                completion(data, response, error)
            } catch let err {
                completion(nil, response, error ?? err)
            }
        }
        return task
    }
}
