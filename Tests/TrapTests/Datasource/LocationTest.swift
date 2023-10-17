@testable import Trap
import XCTest
import CoreLocation

class LocationTest: XCTestCase {
    override func setUp() {
        CLLocationManager.enableMock()
    }
    
    override func tearDown() {
        CLLocationManager.disableMock()
    }
    
    func testCoarseLocation() {
        let sendsCompleted = [
            "[109,\(Int64(1.0 * 1000)),11,12,13,14]": expectation(description: "Data 1.0"),
            "[109,\(Int64(3.0 * 1000)),13,14,15,16]": expectation(description: "Data 2.0"),
            "[109,\(Int64(5.0 * 1000)),15,16,17,18]": expectation(description: "Data 3.0"),
            "[109,\(Int64(7.0 * 1000)),17,18,19,20]": expectation(description: "Data 4.0"),
        ]
        
        let collector = TrapLocationCollector()
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard let json = try? JSONEncoder().encode(data) else {
                return
            };

            guard let output = String(data: json, encoding: .utf8) else {
                return
            }
            
            sendsCompleted[output]?.fulfill()
        }
        collector.delegate = delegate
        collector.start()
        
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        
        collector.stop()

#if compiler(>=5.4.2)
        if #available(iOS 14, *) {
            XCTAssertEqual(collector.checkConfiguration(), false)
            XCTAssertEqual(collector.checkPermission(), true)
        }
        
#endif
        XCTAssertNotNil(TrapLocationCollector.instance(withConfig: TrapConfig.DataCollection(), withQueue: OperationQueue()))
    }
    
    func testPreciseLocation() {
        let sendsCompleted = [
            "[109,\(Int64(1.0 * 1000)),11,12,13,14]": expectation(description: "Data 1.0"),
            "[109,\(Int64(3.0 * 1000)),13,14,15,16]": expectation(description: "Data 2.0"),
            "[109,\(Int64(5.0 * 1000)),15,16,17,18]": expectation(description: "Data 3.0"),
            "[109,\(Int64(7.0 * 1000)),17,18,19,20]": expectation(description: "Data 4.0"),
        ]
        
        let collector = TrapPreciseLocationCollector()
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard let json = try? JSONEncoder().encode(data) else {
                return
            };

            guard let output = String(data: json, encoding: .utf8) else {
                return
            }
            
            sendsCompleted[output]?.fulfill()
        }
        collector.delegate = delegate
        collector.start()
        
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        
        collector.stop()

#if compiler(>=5.4.2)
        if #available(iOS 14, *) {
            XCTAssertEqual(collector.checkConfiguration(), false)
            XCTAssertEqual(collector.checkPermission(), true)
        }
#endif
        XCTAssertNotNil(TrapPreciseLocationCollector.instance(withConfig: TrapConfig.DataCollection(), withQueue: OperationQueue()))
    }
}
