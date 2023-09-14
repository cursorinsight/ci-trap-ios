@testable import Trap
import XCTest
import Foundation

class CachedTests: XCTestCase {
    func testCached() {
        let sendCalled = expectation(description: "Send is called")
        let startCalled = expectation(description: "Start is called")
        let stopCalled = expectation(description: "Stop is called")
        let mock = MockTransport()
        mock.sendCalled = { data in
            if data == "Test Data" {
                sendCalled.fulfill()
            }
        }
        mock.startCalled = { startCalled.fulfill() }
        mock.stopCalled = { stopCalled.fulfill() }
        let transport = TrapCachedTransport(with: mock)
        
        transport.start()
        transport.send(data: "Test Data") { error in
            XCTAssertNotNil(error)
        }
        transport.stop()
        
        wait(for: [sendCalled, stopCalled, startCalled], timeout: 1)
    }
}
