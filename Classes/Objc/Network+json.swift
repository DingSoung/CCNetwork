//
//  Network+json.swift
//  Network
//
//  Created by Songwen Ding on 2018/5/3.
//  Copyright © 2018年 DingSoung. All rights reserved.
//

import Foundation

extension Network {
    public class func json(request: URLRequest,
                           trasnform: @escaping ([String: Any]) -> Any?,
                           completion: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask? {
        return Network.json(request: request, trasnform: trasnform, completion: completion)
    }
}
