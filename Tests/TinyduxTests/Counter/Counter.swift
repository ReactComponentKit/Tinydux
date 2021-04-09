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
class CounterStore: Store<CounterState> {

    @Published
    var count: Int = 0
    
    func increment() {
        withState {
            $0.count += 1
        }
    }
    
    func asyncIncrement(value: Int = 1) -> Promise<CounterState> {
        async { state, resolve, reject in
            Thread.sleep(forTimeInterval: 1)
            resolve(state.copy { (mutation) in
                mutation.count += value
            })
        }
        .then {
            self.count = $0.count
        }
    }
    
    func asyncIncrement3x(value: Int) -> Promise<CounterState> {
        flow(action: CounterAction.increment(value), [
            { state, _ in
                return Promise { resolve, _ in
                    Thread.sleep(forTimeInterval: 3)
                    resolve(state)
                }
            },
            inc1,
            inc1,
            inc1,
            { state, _ in
                return Promise { resolve, _ in
                    Thread.sleep(forTimeInterval: 3)
                    resolve(state)
                }
            },
        ])
        .then {
            self.count = $0.count
        }
    }
}

func inc1(state: CounterState, action: CounterAction) -> Promise<CounterState> {
    Promise { resolve, _ in
        resolve(state.copy({ (mutation) in
            switch action {
            case .increment(let value):
                mutation.count += value
            }
        }))
    }
}
