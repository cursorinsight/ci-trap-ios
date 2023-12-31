import CoreMotion

let gyroscopeEventType = 104

/// The gyroscope sensor data collector.
public class TrapGyroscopeCollector: TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private var motionManager: CMMotionManager
    private let queue: OperationQueue

    /// Create a gyroscope sensor collector instance.
    public init(withQueue queue: OperationQueue? = nil) {
        self.queue = queue ?? TrapSensor.queue
        motionManager = CMMotionManager()
    }

    public func checkConfiguration() -> Bool {
        let sensorOk = motionManager.isGyroAvailable
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
        motionManager.gyroUpdateInterval = config.gyroscopeSamplingRate
        motionManager.startGyroUpdates(to: queue) { [weak self] data, _ in
            guard let this = self else {
                assertionFailure("Accelerometer collector empty on update")
                return
            }
            guard let rotationRate = data?.rotationRate else {
                assertionFailure("Gyroscope data was empty")
                return
            }

            let timestamp = TrapTime.normalizeTime(data?.timestamp ?? 0)
            this.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(gyroscopeEventType), // Event type
                DataType.int64(timestamp), // Timestamp
                DataType.double(Double(rotationRate.x)), // X direction
                DataType.double(Double(rotationRate.y)), // Y direction
                DataType.double(Double(rotationRate.z)) // Z direction
            ]))
        }
    }

    public func stop() {
        motionManager.stopGyroUpdates()
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapGyroscopeCollector()
    }
}
