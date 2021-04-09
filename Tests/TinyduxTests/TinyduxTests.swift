import XCTest
@testable import Tinydux

final class CounterStoreTests: XCTestCase {
    
    func testInitStore() {
        let store = CounterStore()
        XCTAssertEqual(store.state.count, 0)
    }
    
    func testIncrement() {
        let store = CounterStore()
        store.increment()
        XCTAssertEqual(store.state.count, 1)
    }
    
    func testAsyncIncrement() {
        let expectation = XCTestExpectation(description: "testAsyncIncrement")
        let store = CounterStore()
        store.asyncIncrement()
            .then { _ in
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.state.count, 1)
    }
    
    func testAsyncIncrement2() {
        let expectation = XCTestExpectation(description: "testAsyncIncrement2")
        let store = CounterStore()
        store.asyncIncrement3x(value: 1)
            .then { _ in
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(store.count, 3)
        XCTAssertEqual(store.state.count, 3)
    }

    static var allTests = [
        ("initStore", testInitStore),
    ]
}
