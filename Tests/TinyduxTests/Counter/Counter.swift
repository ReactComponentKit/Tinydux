//
//  Counter.swift
//  Tinydux
//
//  Created by burt on 2021/04/09.
//

import Foundation
import Promises

enum CounterAction: Action {
    case increment(Int)
}

struct CounterState: State {
    var count: Int = 0
}

@available(iOS 13.0, *)
class CounterStore: Store<CounterState>, ObservableObject {
    func increment() -> Promise<CounterState> {
        withState {
            $0.count += 1
        }
    }
    
    func asyncIncrement(value: Int = 1) -> Promise<CounterState> {
        async { context, resolve, reject in
            guard let store = context() else { return reject(StoreError.invalidPromiseLife) }
            Thread.sleep(forTimeInterval: 1)
            resolve(store.state.copy { (mutation) in
                mutation.count += value
            })
        }
    }
    
    func asyncIncrement3x(value: Int) -> Promise<CounterState> {
        flow(action: CounterAction.increment(value), [
            sleep,
            inc1,
            inc1,
            inc1,
            sleep
        ])
    }
}

func sleep(action: CounterAction, context: @escaping Context<CounterState>) -> Promise<CounterState> {
    Promise { resolve, reject in
        guard let store = context() else { return reject(StoreError.invalidPromiseLife) }
        Thread.sleep(forTimeInterval: 3)
        resolve(store.state)
    }
}

func inc1(action: CounterAction, context: @escaping Context<CounterState>) -> Promise<CounterState> {
    Promise { resolve, reject in
        guard let store = context() else { return reject(StoreError.invalidPromiseLife) }
        resolve(store.state.copy({ (mutation) in
            switch action {
            case .increment(let value):
                mutation.count += value
            }
        }))
    }
}
