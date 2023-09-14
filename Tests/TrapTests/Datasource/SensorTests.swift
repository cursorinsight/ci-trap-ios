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
        let startAccelerometerCalled = expectation(description: "startAccelerometer is called")
        CMMotionManager.startAccelerometerCalled = { startAccelerometerCalled.fulfill() }
        
        let stopAccelerometerCalled = expectation(description: "stopAccelerometer is called")
        CMMotionManager.stopAccelerometerCalled = { stopAccelerometerCalled.fulfill() }
        
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
        wait(for: [startAccelerometerCalled], timeout: 1)
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        collector.stop()
        wait(for: [stopAccelerometerCalled], timeout: 1)
        
        XCTAssertNotNil(TrapAccelerometerCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
        XCTAssertEqual(collector.checkConfiguration(), false)
        XCTAssertEqual(collector.checkPermission(), true)
    }
    
    func testGravity() throws {
        let startGravityCalled = expectation(description: "startGravity is called")
        CMMotionManager.startGravityCalled = { startGravityCalled.fulfill() }
        
        let stopGravityCalled = expectation(description: "stopGravity is called")
        CMMotionManager.stopGravityCalled = { stopGravityCalled.fulfill() }
        
        let sendsCompleted = [
            "[105,\(TrapTime.normalizeTime(1.0)),2,-1,-2]": expectation(description: "Data point 1.0"),
            "[105,\(TrapTime.normalizeTime(3.0)),4,-3,-4]": expectation(description: "Data point 2.0"),
            "[105,\(TrapTime.normalizeTime(5.0)),6,-5,-6]": expectation(description: "Data point 3.0")
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
        
        let collector = TrapGravityCollector()
        collector.delegate = delegateMock
        collector.start()
        wait(for: [startGravityCalled], timeout: 1)
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        collector.stop()
        wait(for: [stopGravityCalled], timeout: 1)
        
        XCTAssertNotNil(TrapGravityCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
        XCTAssertEqual(collector.checkConfiguration(), false)
        XCTAssertEqual(collector.checkPermission(), true)
    }
    
    func testGyroscope() throws {
        let startGyroscopeCalled = expectation(description: "startGyroscope is called")
        CMMotionManager.startGyroscopeCalled = { startGyroscopeCalled.fulfill() }
        
        let stopGyroscopeCalled = expectation(description: "stopGyroscope is called")
        CMMotionManager.stopGyroscopeCalled = { stopGyroscopeCalled.fulfill() }
        
        let sendsCompleted = [
            "[104,\(TrapTime.normalizeTime(1.0)),2,-1,-2]": expectation(description: "Data point 1.0"),
            "[104,\(TrapTime.normalizeTime(3.0)),4,-3,-4]": expectation(description: "Data point 2.0"),
            "[104,\(TrapTime.normalizeTime(5.0)),6,-5,-6]": expectation(description: "Data point 3.0")
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
        
        let collector = TrapGyroscopeCollector()
        collector.delegate = delegateMock
        collector.start()
        wait(for: [startGyroscopeCalled], timeout: 1)
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        collector.stop()
        wait(for: [stopGyroscopeCalled], timeout: 1)
        
        XCTAssertNotNil(TrapGyroscopeCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
        XCTAssertEqual(collector.checkConfiguration(), false)
        XCTAssertEqual(collector.checkPermission(), true)
    }
    
    func testMagnetometer() throws {
        let startMagnetometerCalled = expectation(description: "startMagnetometer is called")
        CMMotionManager.startMagnetometerCalled = { startMagnetometerCalled.fulfill() }
        
        let stopMagnetometerCalled = expectation(description: "stopMagnetometer is called")
        CMMotionManager.stopMagnetometerCalled = { stopMagnetometerCalled.fulfill() }
        
        let sendsCompleted = [
            "[106,\(TrapTime.normalizeTime(1.0)),2,-1,-2]": expectation(description: "Data point 1.0"),
            "[106,\(TrapTime.normalizeTime(3.0)),4,-3,-4]": expectation(description: "Data point 2.0"),
            "[106,\(TrapTime.normalizeTime(5.0)),6,-5,-6]": expectation(description: "Data point 3.0")
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
        
        let collector = TrapMagnetometerCollector()
        collector.delegate = delegateMock
        collector.start()
        wait(for: [startMagnetometerCalled], timeout: 1)
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        collector.stop()
        wait(for: [stopMagnetometerCalled], timeout: 1)
        
        XCTAssertNotNil(TrapMagnetometerCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
        XCTAssertEqual(collector.checkConfiguration(), false)
        XCTAssertEqual(collector.checkPermission(), true)
    }
}
