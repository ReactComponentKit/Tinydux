//
//  Sleep.swift
//  TinyduxTests
//
//  Created by burt on 2021/11/08.
//

import Foundation
import Promises

func Sleep(_ interval: TimeInterval) -> Promise<TimeInterval> {
    Promise<TimeInterval>(on: .global()) { resolve, reject in
        Thread.sleep(forTimeInterval: interval)
        resolve(interval)
    }
}
