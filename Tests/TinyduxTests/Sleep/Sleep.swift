//
//  Sleep.swift
//  TinyduxTests
//
//  Created by burt on 2021/11/08.
//

import Foundation
import Promises

func Sleep(_ interval: TimeInterval) -> Promise<Void> {
    return Promise { () -> Void in
        Thread.sleep(forTimeInterval: interval)
    }
}
