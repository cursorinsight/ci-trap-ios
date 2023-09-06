@testable import Trap
import CoreMotion
import XCTest

final class SensorTests: XCTestCase {
    func testExample() throws {
        CMMotionManager.enableMock()
        let manager = CMMotionManager()
        let updateExpectation = expectation(description: "Accelerometer is called")
        manager.startAccelerometerUpdates(to: OperationQueue.main) { data, _ in
            print("UPDATES")
            updateExpectation.fulfill()
        }
        wait(for: [updateExpectation], timeout: 3)
        manager.stopAccelerometerUpdates()
    }
}
