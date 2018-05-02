//
//  URLRequest+dataTask.swift
//  Network
//
//  Created by Songwen Ding on 2018/5/2.
//  Copyright © 2018年 DingSoung. All rights reserved.
//

import Foundation

extension URLRequest {
    // MARK: - process request
    @discardableResult public func dataTask(session: URLSession = .shared,
                                            completion: @escaping ((Any?, URLResponse?, Error?) -> Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: self) { (data, response, error) in
            do {
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data)
                    completion(json, response, error)
                } else {
                    completion(data, response, error)
                }
            } catch let error {
                completion(data, response, error)
            }
        }
        return task
    }
}
