//
//  Stte.swift
//  FBLPromises
//
//  Created by burt on 2021/04/09.
//

import Foundation

public protocol State {
    init()
}

extension State {
    public func copy(_ mutate: (_ mutableState: inout Self) -> Void) -> Self {
        var mutableState = self
        mutate(&mutableState)
        return mutableState
    }
}
