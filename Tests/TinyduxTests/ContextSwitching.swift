//
//  ContextSwitching.swift
//  TinyduxTests
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Promises

/// for testing the computed property
func contextSwitching() -> Promise<Void> {
    return Promise { () -> Void in
        Thread.sleep(forTimeInterval: 0.1)
    }
}
