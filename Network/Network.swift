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
