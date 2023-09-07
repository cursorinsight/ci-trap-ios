@testable import Trap
import CoreMotion
import XCTest

final class SensorTests: XCTestCase {
    override func setUp() {
        CMMotionManager.enableMock()
    }
    
    override func tearDown() {
        CMMotionManager.disableMock()
    }
    
    func testAccelerometer() throws {
        let sendsCompleted = [
            "[103,\(TrapTime.normalizeTime(1.0)),2,-1,-2]": expectation(description: "Data point 1.0"),
            "[103,\(TrapTime.normalizeTime(3.0)),4,-3,-4]": expectation(description: "Data point 2.0"),
            "[103,\(TrapTime.normalizeTime(5.0)),6,-5,-6]": expectation(description: "Data point 3.0")
        ];
        
        let delegateMock = TrapDatasourceDelegateMock()
        delegateMock.saveHandler = { seq, data in
            guard let json = try? JSONEncoder().encode(data) else {
                return
            };

            guard let output = String(data: json, encoding: .utf8) else {
                return
            }
            
            sendsCompleted[output]?.fulfill()
        }
        
        let collector = TrapAccelerometerCollector()
        collector.delegate = delegateMock
        collector.start()
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        collector.stop()
    }
}
