@testable import Trap
import XCTest
import CoreBluetooth

@available(iOS 13.1, *)
final class BluetoothTest: XCTestCase {
    lazy var collector: TrapBluetoothCollector = {
        let collector = TrapBluetoothCollector()
        collector.manager = MockCBCentralManager()

        return collector
    }()

    func testBluetooth() {
        class MockProtocol: NSObject, CBPeripheralProtocol {
            var name: String? = "Test Device"
            
            var identifier: UUID = UUID(uuidString: "1698DFB1-B8BB-432F-A975-306DD31A29F4")!
            
            var state: CBPeripheralState = .connected
        }
        let peripheral: CBPeripheralProtocol = MockProtocol()
        
        class MockProtocol2: NSObject, CBPeripheralProtocol {
            var name: String? = "Device Test"
            
            var identifier: UUID = UUID(uuidString: "1698DFB1-B8BB-432F-A975-306DD31A29F4")!
            
            var state: CBPeripheralState = .connected
        }
        let peripheral2: CBPeripheralProtocol = MockProtocol2()
        
        class CentralManager: CBCentralManagerProtocol {
            var state: CBManagerState = .poweredOn
            
            var isScanning: Bool = true
            
            func stopScan() {
                print("stopScan")
            }
            
            func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?) {
                print("connectionEvents")
            }
            
            func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
                print("scan")
            }
        }
        let manager = CentralManager()

        let deviceIdentified = expectation(description: "A Bluetooth device is properly identified")
        let deviceJoined = expectation(description: "A Bluetooth device has just joined")

        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data else {
                XCTFail("Invalid DataType in frame position")
                return
            }
            guard case let DataType.int(eventType) = frame[0] else {
                XCTFail("Invalid DataType in 1st position")
                return
            }
            guard case DataType.int64(_) = frame[1] else {
                XCTFail("Invalid DataType in 1st position")
                return
            }
            guard case let DataType.array(devices) = frame[2] else {
                XCTFail("Invalid DataType in 2nd position")
                return
            }
            guard case let DataType.array(device) = devices[0] else {
                XCTFail("Invalid DataType in devices")
                return
            }
            guard case let DataType.string(name) = device[0] else {
                XCTFail("Invalid DataType in 1st device position")
                return
            }
            guard case let DataType.string(uuid) = device[1] else {
                XCTFail("Invalid DataType in 2nd device position")
                return
            }
            guard case let DataType.int(state) = device[2] else {
                XCTFail("Invalid DataType in 3rd device position")
                return
            }

            if (name == "Test Device") {
                XCTAssertEqual(eventType, 108)
                XCTAssertEqual(name, "Test Device")
                XCTAssertEqual(uuid, "1698DFB1-B8BB-432F-A975-306DD31A29F4")
                XCTAssertEqual(state, 3)
                deviceIdentified.fulfill()
            } else {
                XCTAssertEqual(eventType, 108)
                XCTAssertEqual(name, "Device Test")
                XCTAssertEqual(uuid, "1698DFB1-B8BB-432F-A975-306DD31A29F4")
                XCTAssertEqual(state, 3)
                deviceJoined.fulfill()
            }
        }
        collector.delegate = delegate
        collector.manager = manager
        collector.start()

        collector.centralManager(manager, didDiscover: peripheral, advertisementData: [:], rssi: NSNumber(0))
        collector.centralManager(manager, connectionEventDidOccur: CBConnectionEvent(rawValue: 0)!, for: peripheral2)

        wait(for: [deviceIdentified, deviceJoined], timeout: 1)
        
        collector.stop()
        
        XCTAssertNotNil(TrapBluetoothCollector.instance(withConfig: Config(), withQueue: OperationQueue()))
    }
}
