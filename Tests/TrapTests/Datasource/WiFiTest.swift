@testable import Trap
@testable import NetworkExtension
import XCTest

@available(iOS 14.0, *)
class WiFiTest: XCTestCase {
    override func setUp() {
        NEHotspotNetwork.enableMock()
        NEHotspotHelper.enableMock()
    }
    
    override func tearDown() {
        NEHotspotNetwork.disableMock()
        NEHotspotHelper.disableMock()
    }
    
    func testWiFi() {
#if compiler(>=5.7)
        let initial = expectation(description: "A WiFi network is identified")
        initial.assertForOverFulfill = false
        
        let connected = expectation(description: "A WiFi network connected")
        connected.assertForOverFulfill = false
        
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data else {
                XCTFail("Incorrect DataType of frame")
                return
            }
            guard case let DataType.int(eventType) = frame[0] else {
                XCTFail("Incorrect DataType in 1st position")
                return
            }
            guard case DataType.int64(_) = frame[1] else {
                XCTFail("Incorrect DataType in 2nd position")
                return
            }
            guard case let DataType.array(info) = frame[2] else {
                XCTFail("Incorrect DataType in 3rd position")
                return
            }
            guard case let DataType.string(ssid) = info[0] else {
                XCTFail("Incorrect DataType in 4th position")
                return
            }
            guard case let DataType.string(bssid) = info[1] else {
                XCTFail("Incorrect DataType in 5th position")
                return
            }
            guard case DataType.int(_) = info[2] else {
                XCTFail("Incorrect DataType in 6th position")
                return
            }
            XCTAssertEqual(eventType, 107)
            if ssid == "Test Network" {
                XCTAssertEqual(ssid, "Test Network")
                XCTAssertEqual(bssid, "01:23:45:67:89:AB:CD:EF")
                initial.fulfill()
            }
            if ssid == "Network Just Connected" {
                XCTAssertEqual(ssid, "Network Just Connected")
                XCTAssertEqual(bssid, "EF:CD:AB:89:67:45:23:01")
                connected.fulfill()
            }
        }
        let collector = TrapWiFiCollector()
        collector.delegate = delegate
        collector.start()
        wait(for: [initial, connected], timeout: 1)
        collector.stop()
        
        XCTAssertNotNil(TrapWiFiCollector.instance(withConfig: Config(), withQueue: OperationQueue()))
        XCTAssertEqual(collector.checkConfiguration(), false)
        XCTAssertEqual(collector.checkPermission(), false)
#endif
    }
}
