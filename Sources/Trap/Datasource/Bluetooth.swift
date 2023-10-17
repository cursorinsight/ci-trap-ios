import CoreBluetooth

let bluetoothEventType = 108

/// A collector type which continuously monitors for Bluetooth LE devices.
@available(iOS 13.1, *)
public class TrapBluetoothCollector: CBCentralManagerDelegateProxy, CBCentralManagerDelegateProtocol, TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    open var manager: CBCentralManagerProtocol?
    private var peripherals: [UUID]

    /// Create a collector which listens for Bluetooth devices.
    public override init() {
        peripherals = [UUID]()
        super.init()
        target = self
    }

    public func checkConfiguration() -> Bool {
        let bundleOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSBluetoothAlwaysUsageDescription") ?? false
        let available = manager?.state != .unsupported

        return bundleOk && available
    }

    public func checkPermission() -> Bool {
        switch CBManager.authorization {
        case .notDetermined:
            return true
        case .restricted:
            return true
        case .denied:
            return false
        case .allowedAlways:
            return true
        @unknown default:
            return false
        }
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        manager = manager ?? setupCentral()
        success()
    }

    public func start(withConfig _: TrapConfig.DataCollection) {
        if checkPermission(), manager == nil {
            manager = setupCentral()
        }
    }

    public func stop() {
        if manager?.isScanning != nil {
            manager?.stopScan()
        }

        manager = nil
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapBluetoothCollector()
    }

    private func setupCentral() -> CBCentralManager {
        CBCentralManager(
            delegate: self,
            queue: DispatchQueue.global(qos: .background)
        )
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManagerProtocol) {
        switch central.state {
        case .poweredOff:
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        case .poweredOn:
            central.registerForConnectionEvents(options: nil)
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            break
        }
    }

    /// Implementation of CBCentralManagerDelegate. Called when
    /// a new BLE device is discovered.
    public func centralManager(
        _: CBCentralManagerProtocol,
        didDiscover peripheral: CBPeripheralProtocol,
        advertisementData: [String: Any],
        rssi _: NSNumber
    ) {
        guard let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        let id = peripheral.identifier

        if peripherals.contains(id) {
            return
        } else {
            peripherals.append(id)
        }

        let timestamp = TrapTime.getCurrentTime()
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(bluetoothEventType),
            DataType.int64(timestamp),
            DataType.array([
                DataType.array([
                    DataType.string(name),
                    DataType.string(id.uuidString),
                    DataType.int(peripheral.state == CBPeripheralState.connected ? 3 : 1)
                ])
            ])
        ]))
    }

    /// Implementation of CBCentralManagerDelegate. Called when
    /// a new BLE device is connected.
    public func centralManager(
        _: CBCentralManagerProtocol,
        connectionEventDidOccur _: CBConnectionEvent,
        for peripheral: CBPeripheralProtocol
    ) {
        guard let name = peripheral.name else { return }
        let id = peripheral.identifier

        let timestamp = TrapTime.getCurrentTime()
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(bluetoothEventType),
            DataType.int64(timestamp),
            DataType.array([
                DataType.array([
                    DataType.string(name),
                    DataType.string(id.uuidString),
                    DataType.int(3)
                ])
            ])
        ]))
    }
}

// The abstraction is needed for testing purposes

public protocol CBCentralManagerProtocol {
    var state: CBManagerState { get }

    var isScanning: Bool { get }

    func stopScan()

    @available(iOS 13.0, *)
    func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]?)

    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
}

extension CBCentralManager: CBCentralManagerProtocol {}

public protocol CBPeripheralProtocol {
    var name: String? { get }

    var identifier: UUID { get }

    var state: CBPeripheralState { get }
}

extension CBPeripheral: CBPeripheralProtocol {}

public protocol CBCentralManagerDelegateProtocol {
    func centralManagerDidUpdateState(_ central: CBCentralManagerProtocol)

    func centralManager(
        _: CBCentralManagerProtocol,
        didDiscover peripheral: CBPeripheralProtocol,
        advertisementData: [String: Any],
        rssi _: NSNumber
    )

    func centralManager(
        _: CBCentralManagerProtocol,
        connectionEventDidOccur _: CBConnectionEvent,
        for peripheral: CBPeripheralProtocol
    )
}

public class CBCentralManagerDelegateProxy: NSObject, CBCentralManagerDelegate {
    var target: CBCentralManagerDelegateProtocol?

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        target?.centralManagerDidUpdateState(central as CBCentralManagerProtocol)
    }

    public func centralManager(
        _ manager: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        target?.centralManager(manager as CBCentralManagerProtocol, didDiscover: peripheral as CBPeripheralProtocol, advertisementData: advertisementData, rssi: rssi)
    }

    public func centralManager(
        _ manager: CBCentralManager,
        connectionEventDidOccur event: CBConnectionEvent,
        for peripheral: CBPeripheral
    ) {
        target?.centralManager(manager as CBCentralManagerProtocol, connectionEventDidOccur: event, for: peripheral as CBPeripheralProtocol)
    }
}
