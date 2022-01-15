import XCTest
import Promises
@testable import Tinydux

final class CounterStoreTests: XCTestCase {
    
    private var store: CounterStore!
        
    override func setUp() {
        super.setUp()
        store = CounterStore()
    }
    
    override func tearDown() {
        super.tearDown()
        store = nil
    }
    
    func testInitStore() {
        XCTAssertEqual(store.state.count, 0)
    }
    
    func testIncrementAction() {
        store.incrementAction(payload: 1)
        XCTAssertEqual(store.state.count, 1)
        store.incrementAction(payload: 10)
        XCTAssertEqual(store.state.count, 11)
    }
    
    func testDecrementAction() {
        store.decrementAction(payload: 1)
        XCTAssertEqual(store.state.count, -1)
        store.decrementAction(payload: 10)
        XCTAssertEqual(store.state.count, -11)
    }
    
    func testAsyncIncrementAction() {
        let expectation1 = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncIncrementAction(payload: 1)
            .then { _ in
                expectation1.fulfill()
            }
        wait(for: [expectation1], timeout: 5)
        XCTAssertEqual(store.state.count, 1)
        
        let expectation2 = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncIncrementAction(payload: 10)
            .then { _ in
                expectation2.fulfill()
            }
        wait(for: [expectation2], timeout: 5)
        XCTAssertEqual(store.state.count, 11)
    }
    
    func testAsyncDecrementAction() {
        let expectation1 = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncDecrementAction(payload: 1)
            .then { _ in
                expectation1.fulfill()
            }
        wait(for: [expectation1], timeout: 5)
        XCTAssertEqual(store.state.count, -1)
        
        let expectation2 = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncDecrementAction(payload: 10)
            .then { _ in
                expectation2.fulfill()
            }
        wait(for: [expectation2], timeout: 5)
        XCTAssertEqual(store.state.count, -11)
    }
    
    func testMultipleAsyncIncrementAction() {
        let expectation = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncIncrementAction(payload: 1)
            .then { [unowned store] _ in
                return store!.asyncIncrementAction(payload: 10)
            }
            .then { [unowned store] _ in
                return store!.asyncIncrementAction(payload: 20)
            }
            .then { _ in
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(store.state.count, 31)
        XCTAssertEqual(store.count, 31)
    }
    
    func testMultipleAsyncDecrementAction() {
        let expectation = XCTestExpectation(description: "testAsyncIncrementAction")
        store.asyncDecrementAction(payload: 1)
            .then { [unowned store] _ in
                return store!.asyncDecrementAction(payload: 10)
            }
            .then { [unowned store] _ in
                return store!.asyncDecrementAction(payload: 20)
            }
            .then { _ in
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(store.state.count, -31)
        XCTAssertEqual(store.count, -31)
    }
}
