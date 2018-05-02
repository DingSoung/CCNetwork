//  Created by Songwen Ding on 2017/8/16.
//  Copyright © 2017年 DingSoung. All rights reserved.

import UIKit

@objc extension URLSessionDataTask {
    // MARK: - process request
    @discardableResult public class func data(request: URLRequest, session: URLSession = .shared, completion: @escaping ((Any?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionDataTask? {
        let task = session.dataTask(with: request) { (data, response, error) in
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

    // MARK: - Download Task
    @discardableResult open class func download(request: URLRequest, session: URLSession = .shared, completion: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionDownloadTask? {
        let task = session.downloadTask(with: request) { (url, response, error) in
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
