//
//  Job.swift
//  FBLPromises
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Promises

public typealias Job<S: State, A: Action> = (A, @escaping Context<S>) -> Promise<S>
