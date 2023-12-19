import UIKit
let batteryEventType = 133

public class TrapBatteryCollector: NSObject, TrapDatasource {
    public var delegate: TrapDatasourceDelegate?

    public func checkConfiguration() -> Bool {
        true // Always OK
    }

    public func checkPermission() -> Bool {
        true // No permission needed
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        success() // Automatically succeeds, no permission needed
    }

    public func start(withConfig _: TrapConfig.DataCollection) {
        sendBatteryEvent()
    }

    public func stop() {
    }

    public func sendBatteryEvent() {
        let timestamp = TrapTime.getCurrentTime()
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

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapBatteryCollector()
    }
}
