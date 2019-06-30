//  Created by Songwen on 2018/8/28.
//  Copyright © 2018 DingSoung. All rights reserved.

import Foundation

struct NetworkError: Error {
    let code: Code
}

extension NetworkError {
    enum Code: Int {
        case success = 0
        case notJSON = 1
    }
}

extension NetworkError {
    private var message: String {
        switch self.code {
        case .success: return "success"
        case .notJSON: return "phrase json fail"
        }
    }
}

extension NetworkError: LocalizedError {
    internal var errorDescription: String? { return self.message }
    internal var failureReason: String? { return self.message }
    internal var recoverySuggestion: String? { return "Please Check" }
    internal var helpAnchor: String? { return "Update to Latest version" }
}
