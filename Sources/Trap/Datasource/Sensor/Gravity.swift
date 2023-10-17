import CoreMotion

let gravityEventType = 105

/// The gyroscope sensor data collector.
public class TrapGravityCollector: TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private var motionManager: CMMotionManager
    private let queue: OperationQueue

    /// Create a gravity sensor collector instance.
    public init(withQueue queue: OperationQueue? = nil) {
        self.queue = queue ?? TrapSensor.queue
        motionManager = CMMotionManager()
    }

    public func checkConfiguration() -> Bool {
        let sensorOk = motionManager.isDeviceMotionAvailable
        let bundleOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSMotionUsageDescription") ?? false

        return sensorOk && bundleOk
    }

    public func checkPermission() -> Bool {
        true
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        success()
    }

    public func start(withConfig config: TrapConfig.DataCollection) {
        motionManager.deviceMotionUpdateInterval = config.gravitySamplingRate
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let this = self else {
                assertionFailure("Accelerometer collector empty on update")
                return
            }
            guard let gravity = data?.gravity else {
                assertionFailure("Gravity data was empty")
                return
            }

            let timestamp = TrapTime.normalizeTime(data?.timestamp ?? 0)
            this.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(gravityEventType), // Event type
                DataType.int64(timestamp), // Timestamp
                DataType.double(Double(gravity.x)), // X direction
                DataType.double(Double(gravity.y)), // Y direction
                DataType.double(Double(gravity.z)) // Z direction
            ]))
        }
    }

    public func stop() {
        motionManager.stopDeviceMotionUpdates()
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapGravityCollector()
    }
}
