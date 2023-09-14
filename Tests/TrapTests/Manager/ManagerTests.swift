@testable import Trap
import XCTest

class ManagerTests: XCTestCase {
    func testRunHalt() throws {
        let startCalled = expectation(description: "Start called")
        let stopCalled = expectation(description: "Stop called")
        MockCollector.startCalled = { startCalled.fulfill() }
        MockCollector.stopCalled = { stopCalled.fulfill() }
        var config = TrapConfig()
        config.collectors = []
        var manager: TrapManager? = try TrapManager(withConfig: config, withReporterQueue: nil, withCollectorQueue: nil)
        let mockCollector = MockCollector()
        try manager!.run(collector: mockCollector)
        manager = nil
        
        wait(for: [startCalled, stopCalled], timeout: 1)
    }
    
    func testRunAll() throws {
        let startCalled = expectation(description: "Start called")
        let stopCalled = expectation(description: "Stop called")
        MockCollector.startCalled = { startCalled.fulfill() }
        MockCollector.stopCalled = { stopCalled.fulfill() }
        var config = TrapConfig()
        config.collectors = [MockCollector.self]
        var manager: TrapManager? = try TrapManager(withConfig: config, withReporterQueue: nil, withCollectorQueue: nil)
        try manager?.runAll()
        manager = nil
        
        wait(for: [startCalled, stopCalled], timeout: 1)
    }
}
