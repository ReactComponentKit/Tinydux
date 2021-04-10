//
//  Context.swift
//  Tinydux
//
//  Created by burt on 2021/04/10.
//

import Foundation

public typealias Context<S: State> = () -> Store<S>?
