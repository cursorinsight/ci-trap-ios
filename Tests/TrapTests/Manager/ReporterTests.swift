@testable import Trap
import XCTest
import Foundation

class ReporterTests: XCTestCase {
    func testReporter() throws {
        let sendCompleted = expectation(description: "Send initiated")
        let mock = MockStorage(withConfig: TrapConfig())
        mock.makeIteratorCalled = { sendCompleted.fulfill(); }
        let reporter = TrapReporter(OperationQueue(), mock, TrapConfig())
        
        try reporter.start()
        wait(for: [sendCompleted], timeout: 5)
        reporter.stop()
    }
}
