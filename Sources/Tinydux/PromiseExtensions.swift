//
//  PromiseExtensions.swift
//  Tinydux
//
//  Created by burt on 2021/11/08.
//

import Foundation
import Promises

extension Promise {
    public func run() {
        self.then { _ in }
    }
}
