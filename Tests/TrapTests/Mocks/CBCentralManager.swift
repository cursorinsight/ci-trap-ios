import Trap
import CoreBluetooth

class MockCBCentralManager: CBCentralManager {
    public init() {
        super.init(delegate: nil, queue: DispatchQueue.main, options: nil)
    }
}
