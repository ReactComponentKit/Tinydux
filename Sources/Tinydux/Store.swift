//
//  Store.swift
//  FBLPromises
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Promises

open class Store<S: State> {
    public private(set) var state: S
        
    public init(state: S = S()) {
        self.state = state
    }
    
    @discardableResult
    public func withState(_ mutation: (inout S) -> Void) -> S{
        mutation(&state)
        return state
    }
    
    public func async(on queue: DispatchQueue = .global(), _ work: @escaping (S, @escaping (S) -> Void, @escaping (Error) -> Void) throws -> Void) -> Promise<S> {
        return Promise<S>(on: queue) { [weak self] resolve, reject in
            do {
                guard let s = self?.state else {
                    reject(StoreError.invalidPromiseLife)
                    return
                }
                try work(s, resolve, reject)
            } catch {
                throw error
            }
        }
        .then { [weak self] in
            self?.state = $0
        }
    }
    
    public func flow<A: Action>(action: A, _ jobs: [Job<S, A>]) -> Promise<S> {
        async(on: .global()) { state, resolve, reject in
            do {
                var mutableState = state
                for job in jobs {
                    mutableState = try await(job(mutableState, action))
                }
                resolve(mutableState)
            } catch {
                if let err = error as? StoreError, err == StoreError.invalidPromiseLife {
                    resolve(state)
                } else {

                }
            }
        }
    }
}
