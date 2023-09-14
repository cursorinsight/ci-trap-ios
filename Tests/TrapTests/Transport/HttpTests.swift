@testable import Trap
import XCTest
import Foundation

class HttpTests: XCTestCase {
    func testSend() {
        let sendCalled = expectation(description: "Send is called")
        let transport = TrapHttpTransport(URL(string: "http://127.0.0.1")!)
        transport.start()
        transport.send(data: "Test Data") { error in
            XCTAssertNotNil(error)
            sendCalled.fulfill()
        }
        transport.stop()
        wait(for: [sendCalled], timeout: 1)
    }
}
