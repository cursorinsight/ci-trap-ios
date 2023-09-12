import Trap
import CoreBluetooth

class MockCBCentralManager: CBCentralManager {
    override var state: CBManagerState {
        get {
            return .poweredOn
        }
    }
    
    override var isScanning: Bool {
        get {
            return true
        }
    }
    
    var stopScanCalled: (() -> Void)?
    
    override func stopScan() {
        stopScanCalled?()
    }
    
    public init() {
        super.init(delegate: nil, queue: DispatchQueue.main, options: nil)
    }
}
