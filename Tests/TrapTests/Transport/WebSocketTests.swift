@testable import Trap
import Foundation
import XCTest

class WebSocketTests: XCTestCase {
    
    func testSend() {
        let sendCalled = expectation(description: "Send is called")
        let transport = TrapWebsocketTransport(URL(string: "ws://127.0.0.1")!)
        transport.start()
        transport.send(data: "Test Data") { error in
            XCTAssertNotNil(error)
            sendCalled.fulfill()
        }
        
        wait(for: [sendCalled], timeout: 1)
    }
}
