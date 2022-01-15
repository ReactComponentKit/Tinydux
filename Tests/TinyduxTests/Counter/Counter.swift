//
//  Counter.swift
//  Tinydux
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Tinydux
import Promises
import Combine

struct Counter: State {
    var count: Int = 0
}

class CounterStore: Store<Counter> {
    init() {
        super.init(state: Counter())
    }
    
    @Published
    var count = 0
    
    override func computed(new: Counter, old: Counter) {
        self.count = new.count
    }
    
    // mutation
    private func INCREMENT(counter: inout Counter, payload: Int) {
        counter.count += payload
    }
    
    private func DECREMENT(counter: inout Counter, payload: Int) {
        counter.count -= payload
    }
    
    // actions
    func incrementAction(payload: Int) {
        commit(mutation: INCREMENT, payload: payload)
    }
    
    func decrementAction(payload: Int) {
        commit(mutation: DECREMENT, payload: payload)
    }
    
    func asyncIncrementAction(payload: Int) -> Promise<Counter> {
        asyncTask { [weak self] in
            guard let self = self else { return }
            _ = try awaitPromise(Sleep(1))
            self.commit(mutation: self.INCREMENT, payload: payload)
        }
    }
    
    func asyncDecrementAction(payload: Int) -> Promise<Counter> {
        asyncTask { [weak self] in
            guard let self = self else { return }
            _ = try awaitPromise(Sleep(1))
            self.commit(mutation: self.DECREMENT, payload: payload)
        }
    }
}
