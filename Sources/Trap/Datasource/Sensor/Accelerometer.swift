import CoreMotion

let accelerometerEventType = 103

/// The acceleration sensor data collector.
public class TrapAccelerometerCollector: TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private let motionManager: CMMotionManager
    private let queue: OperationQueue

    /// Creates an accelerometer sensor collector instance.
    public init(withQueue queue: OperationQueue? = nil) {
        self.queue = queue ?? TrapSensor.queue
        motionManager = CMMotionManager()
    }

    public func checkConfiguration() -> Bool {
        let sensorOk = motionManager.isAccelerometerAvailable
        let bundleOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSMotionUsageDescription") ?? false

        return sensorOk && bundleOk
    }

    public func checkPermission() -> Bool {
        true // No runtime permission required
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        success() // Always succeeds
    }

    public func start(withConfig config: TrapConfig.DataCollection) {
        motionManager.accelerometerUpdateInterval = config.accelerationSamplingRate
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let this = self else {
                assertionFailure("Accelerometer collector empty on update")
                return
            }

            guard let acceleration = data?.acceleration else {
                assertionFailure("Acceleration data was empty")
                return
            }

            let timestamp = TrapTime.normalizeTime(data?.timestamp ?? 0)
            this.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(accelerometerEventType), // Event type
                DataType.int64(timestamp), // Timestamp
                DataType.double(Double(acceleration.x)), // X direction
                DataType.double(Double(acceleration.y)), // Y direction
                DataType.double(Double(acceleration.z)) // Z direction
            ]))
        }
    }

    public func stop() {
        motionManager.stopAccelerometerUpdates()
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapAccelerometerCollector(withQueue: queue)
    }
}
