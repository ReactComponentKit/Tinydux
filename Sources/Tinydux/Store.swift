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
    private var workListBeforeCommit: [(S) -> Void] = []
    private var workListAfterCommit: [(S) -> Void] = []
    
    public init(state: S) {
        self.state = state
    }
    
    open func worksBeforeCommit() -> [(S) -> Void] {
            return []
        }
        
    open func worksAfterCommit() -> [(S) -> Void] {
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
            work(self.state)
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
            work(self.state)
        }
    }
    
    private func computeOnMainThread(new: S, old: S) {
        if new != old {
            computed(new: new, old: old)
        }
    }
    
    public func commit<P>(mutation: (inout S, P) -> Void, payload: P) {
        doWorksBeforeCommit()
        let old = state
        mutation(&state, payload)
        doWorksAfterCommit()
        Promise<S>(on: .main) { [weak self] resolve, _ in
            guard let self = self else { return }
            self.computeOnMainThread(new: self.state, old: old)
            resolve(self.state)
        }
        .then {  _ in }
    }
    
    open func computed(new: S, old: S) {
        // override it
    }
    
    public func asyncTask(_ job: @escaping () throws -> Void) -> Promise<S> {
        return Promise<S>(on: .global()) { [weak self] resolve, reject in
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
