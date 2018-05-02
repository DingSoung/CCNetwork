//  Created by Songwen Ding 12/21/15.
//  Copyright © 2015 DingSoung. All rights reserved.

import Foundation

@objcMembers
public final class Network {
    open static let shareSession = { return $0 }(
        URLSession(configuration: SessionConfiguration(),
                   delegate: SessionDelegate(),
                   delegateQueue: OperationQueue())
    )
    fileprivate init() {}
    deinit {}
}

extension Network {
    // TODO: create functiuon to generate request, update request, generate task, manager request, progress response, custom complete queue
    // TODO: support use user delegate
    // TDOD: complete reach ability
}
