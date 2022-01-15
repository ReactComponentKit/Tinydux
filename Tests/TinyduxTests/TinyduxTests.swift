//
//  TinyduxTests.swift
//  TinyduxTests
//
//  Created by burt on 2022/01/15.
//

import XCTest
import Promises
@testable import Tinydux

struct TinyduxState: State {
    var count: Int = 0
}

class TinyduxStore: Store<TinyduxState> {
    init() {
        super.init(state: TinyduxState())
    }
    
    @Published
    var doubleCount: Int = 0
    
    @Published
    var conditionalDoubleEven: Int = 0
    
    override func computed(new: TinyduxState, old: TinyduxState) {
        doubleCount = new.count * 2
        
        if old.count % 2 == 0 && new.count % 2 == 1 {
            conditionalDoubleEven = old.count * 2
        }
    }
}

class WorksBeforeCommitStore: Store<TinyduxState> {
    init() {
        super.init(state: TinyduxState())
    }

    override func worksBeforeCommit() -> [(TinyduxState) -> Void] {
        return [
            { (state) in
                print(state.count)
            }
        ]
    }
}

class WorksAfterCommitStore: Store<TinyduxState> {
    init() {
        super.init(state: TinyduxState())
    }

    override func worksAfterCommit() -> [(TinyduxState) -> Void] {
        return [
            { (state) in
                print(state.count)
            }
        ]
    }
}

final class TinyduxTests: XCTestCase {
    private var store: TinyduxStore!
    
    override func setUp() {
        super.setUp()
        store = TinyduxStore()
    }
    
    override func tearDown() {
        super.tearDown()
        store = nil
    }
    
    func testCommit() {
        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 10)
        XCTAssertEqual(10, store.state.count)
    }
    
    func testWorksBeforeCommit() {
        let store = WorksBeforeCommitStore()
        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 1)
        XCTAssertEqual(1, store.state.count)
        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 1)
        XCTAssertEqual(2, store.state.count)
    }

    func testWorksAfterCommit() async {
        let store = WorksAfterCommitStore()
        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 1)
        try? awaitPromise(contextSwitching())
        XCTAssertEqual(1, store.state.count)

        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 1)
        try? awaitPromise(contextSwitching())
        XCTAssertEqual(2, store.state.count)
    }
    
    func testComputed() async {
        store.commit(mutation: { mutableState, number in
            mutableState.count += number
        }, payload: 10)
        XCTAssertEqual(10, store.state.count)        
        try? awaitPromise(contextSwitching())
        XCTAssertEqual(20, store.doubleCount)
    }
    
    func testContitionalComputed() async {
        for i in 1...10 {
            store.commit(mutation: { mutableState, number in
                mutableState.count += number
            }, payload: i)
        }
        XCTAssertEqual(55, store.state.count)
        try? awaitPromise(contextSwitching())
        XCTAssertEqual(110, store.doubleCount)
        
        // old      new
        // 0        1
        // 10       15
        // 36       45
        XCTAssertEqual(72, store.conditionalDoubleEven)
    }
}
