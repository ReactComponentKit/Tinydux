//
//  Store.swift
//  FBLPromises
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Promises

@dynamicMemberLookup
open class Store<S: State> {
    @Published
    public private(set) var state: S
        
    public init(state: S = S()) {
        self.state = state
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<S, T>) -> T {
        return state[keyPath: keyPath]
    }
    
    @discardableResult
    public func withState(_ mutation: @escaping (inout S) -> Void) -> Promise<S> {
        Promise<S>(on: .main) { [weak self] resolve, reject in
            if var state = self?.state {
                mutation(&state)
                resolve(state)
            } else {
                reject(StoreError.invalidPromiseLife)
            }
        }
        .then(on: .main) {
            self.state = $0
        }
    }
    
    private func handleContext() -> Store<S>? {
        return self
    }
    
    @discardableResult
    public func async(on queue: DispatchQueue = .global(), _ work: @escaping (@escaping Context<S> , @escaping (S) -> Void, @escaping (Error) -> Void) throws -> Void) -> Promise<S> {
        return Promise<S>(on: queue) { [weak self] resolve, reject in
            do {
                guard let strongSelf = self else {
                    return reject(StoreError.invalidPromiseLife)
                }
                try work(strongSelf.handleContext, resolve, reject)
            } catch {
                throw error
            }
        }
        .then(on: .main) {
            self.state = $0
        }
    }

    @discardableResult
    public func flow<A: Action>(action: A, _ jobs: [Job<S, A>]) -> Promise<S> {
        async(on: .global()) { [weak self] context, resolve, reject in
            do {
                for job in jobs {
                    guard let strongSelf = self else {
                        return reject(StoreError.invalidPromiseLife)
                    }
                    let newState = try await(job(action, context))
                    _ = try await(strongSelf.withState({ (mutation) in
                        mutation = newState
                    }))
                }
                
                if let state = self?.state {
                    resolve(state)
                } else {
                    reject(StoreError.invalidPromiseLife)
                }
            } catch {
                reject(StoreError.invalidPromiseLife)
            }
        }
    }
}
