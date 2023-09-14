@testable import Trap
import XCTest
import Foundation

class CachedTests: XCTestCase {
    override func setUp() {
        let cache = TrapFileCache()
        try! cache?.clear()
    }
    
    func testCached() {
        let sendCalled1 = expectation(description: "Send is called")
        let sendCalled2 = expectation(description: "Send is called")
        let sendCalled3 = expectation(description: "Send is called")
        let startCalled = expectation(description: "Start is called")
        let stopCalled = expectation(description: "Stop is called")
        let mock = MockTransport()
        mock.sendCalled = { data in
            if data == "[[999], ]" {
                sendCalled1.fulfill()
            }
            if data == "[[999],]" {
                sendCalled2.fulfill()
            }
            if data == "[[888], ]" {
                sendCalled3.fulfill()
            }
        }
        mock.startCalled = { startCalled.fulfill() }
        mock.stopCalled = { stopCalled.fulfill() }
        let transport = TrapCachedTransport(with: mock)
        
        transport.start()
        mock.error = true
        transport.send(data: "[[999], ]") { error in
            XCTAssertNotNil(error)
        }
        mock.error = false
        transport.send(data: "[[888], ]") { error in
            XCTAssertNil(error)
        }
        
        wait(for: [startCalled, sendCalled1, sendCalled2, sendCalled3], timeout: 1)
        transport.stop()
        wait(for: [stopCalled], timeout: 1)
    }
}
