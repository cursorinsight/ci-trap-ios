import UIKit
let batteryEventType = 132

public class TrapBatteryCollector: NSObject, TrapDatasource {
    public var delegate: TrapDatasourceDelegate?

    public init(withConfig _: TrapConfig? = nil) {
    }

    public func checkConfiguration() -> Bool {
        true // Always OK
    }

    public func checkPermission() -> Bool {
        true // No permission needed
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        success() // Automatically succeeds, no permission needed
    }

    public func start() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil)
        sendBatteryEvent()
    }

    public func stop() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil)
    }

    @objc func batteryDidChange(_ notification: Notification) {
        sendBatteryEvent()
    }
    
    private func sendBatteryEvent() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(batteryEventType),
            DataType.int64(timestamp),
            DataType.float(UIDevice.current.batteryLevel),
            DataType.int(getBatteryState())
        ]))
    }
    
    private func getBatteryState() -> Int {
        switch UIDevice.current.batteryState{
        case .unplugged:
            return 0
        case .charging:
            return 1
        case .full:
            return 2
        case .unknown:
            return -1
        default:
            return -1
        }
    }

    public static func instance(withConfig config: TrapConfig, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapBatteryCollector(withConfig: config)
    }
}
