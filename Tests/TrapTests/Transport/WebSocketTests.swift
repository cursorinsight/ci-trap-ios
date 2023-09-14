@testable import Trap
import Foundation
import XCTest

class WebSocketTests: XCTestCase {
    
    func testSend() {
        let sendCalled = expectation(description: "Send is called")
        let transport = TrapWSKeepaliveForegroundTransport(URL(string: "ws://127.0.0.1")!)
        transport.start()
        transport.send(data: "Test Data") { error in
            XCTAssertNotNil(error)
            sendCalled.fulfill()
        }
        
        transport.latestSend = Date(timeIntervalSince1970: 0)
        transport.ping()
        
        wait(for: [sendCalled], timeout: 1)
        
        transport.stop()
    }
}
