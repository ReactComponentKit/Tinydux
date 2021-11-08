//
//  Store.swift
//  FBLPromises
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Promises

open class Store<S: State>: ObservableObject {
    public private(set) var state: S
    private var workListBeforeCommit: [(inout S) -> Void] = []
    private var workListAfterCommit: [(inout S) -> Void] = []
    
    public init(state: S) {
        self.state = state
    }
    
    open func worksBeforeCommit() -> [(inout S) -> Void] {
            return []
        }
        
    open func worksAfterCommit() -> [(inout S) -> Void] {
        return []
    }
    
    private func doWorksBeforeCommit() {
        if workListBeforeCommit.isEmpty {
            let works = worksBeforeCommit()
            if works.isEmpty {
                return
            }
            workListBeforeCommit = works
        }
        for work in workListBeforeCommit {
            work(&self.state)
        }
    }
    
    private func doWorksAfterCommit() {
        if workListAfterCommit.isEmpty {
            let works = worksAfterCommit()
            if works.isEmpty {
                return
            }
            workListAfterCommit = works
        }
        for work in workListAfterCommit {
            work(&self.state)
        }
    }
    
    private func computeOnMainThread(new: S, old: S) {
        if new != old {
            computed(new: new, old: old)
        }
        // when doing works after commit mutation, computed value should be equal to state value.
        doWorksAfterCommit()
    }
    
    public func commit<P>(mutation: (inout S, P) -> Void, payload: P) {
        doWorksBeforeCommit()
        let old = state
        mutation(&state, payload)
        Promise<S>(on: .main) { [weak self] resolve, _ in
            guard let self = self else { return }
            self.computeOnMainThread(new: self.state, old: old)
            resolve(self.state)
        }
        .then {  _ in }
    }
    
    public func dispatch<P>(action: (Store<S>, P) -> Promise<S>, payload: P) {
        action(self, payload)
            .then(on: .main) { mutated in
                
            }
    }
    
    public func dispatch<P>(action: (Store<S>, P) -> Void, payload: P) {
        action(self, payload)
    }
    
    open func computed(new: S, old: S) {
        // override it
    }
    
    public func asyncTask(_ job: @escaping () throws -> Void) -> Promise<S> {
        return Promise<S> { [weak self] resolve, reject in
            guard let self = self else { return }
            do {
                try job()
                resolve(self.state)
            } catch {
                reject(error)
            }
        }
    }
}
