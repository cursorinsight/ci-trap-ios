import CoreBluetooth

let bluetoothEventType = 108

/// A collector type which continuously monitors for Bluetooth LE devices.
@available(iOS 13.1, *)
public class TrapBluetoothCollector: NSObject, TrapDatasource, CBCentralManagerDelegate {
    public var delegate: TrapDatasourceDelegate?
    private var centralManager: CBCentralManager?
    private var peripherals: [UUID]

    /// Create a collector which listens for Bluetooth devices.
    public init(withConfig _: Config? = nil) {
        peripherals = [UUID]()
    }

    public func checkConfiguration() -> Bool {
        let bundleOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSBluetoothAlwaysUsageDescription") ?? false
        let available = centralManager?.state != .unsupported

        return bundleOk && available
    }

    public func checkPermission() -> Bool {
        switch CBManager.authorization {
        case .notDetermined:
            return false
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
        centralManager = centralManager ?? setupCentral()
        success()
    }

    public func start() {
        if checkPermission(), centralManager == nil {
            centralManager = setupCentral()
        }
    }

    public func stop() {
        if centralManager?.isScanning != nil {
            centralManager?.stopScan()
        }

        centralManager = nil
    }

    public static func instance(withConfig config: Config, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapBluetoothCollector(withConfig: config)
    }

    private func setupCentral() -> CBCentralManager {
        CBCentralManager(
            delegate: self,
            queue: DispatchQueue.global(qos: .background)
        )
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
            central.registerForConnectionEvents()
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            break
        }
    }

    /// Implementation of CBCentralManagerDelegate. Called when
    /// a new BLE device is discovered.
    public func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData _: [String: Any],
        rssi _: NSNumber
    ) {
        guard let name = peripheral.name else { return }
        let id = peripheral.identifier

        if peripherals.contains(id) {
            return
        } else {
            peripherals.append(id)
        }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(bluetoothEventType),
            DataType.int64(timestamp),
            DataType.array([
                DataType.array([
                    DataType.string(name),
                    DataType.string(id.uuidString),
                    DataType.int(peripheral.state == .connected ? 3 : 1)
                ])
            ])
        ]))
    }

    /// Implementation of CBCentralManagerDelegate. Called when
    /// a new BLE device is connected.
    public func centralManager(
        _: CBCentralManager,
        connectionEventDidOccur _: CBConnectionEvent,
        for peripheral: CBPeripheral
    ) {
        guard let name = peripheral.name else { return }
        let id = peripheral.identifier

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(bluetoothEventType),
            DataType.int64(Int64(Date().timeIntervalSince1970 * 1000)),
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
