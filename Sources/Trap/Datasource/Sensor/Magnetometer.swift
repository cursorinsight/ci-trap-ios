import CoreMotion

let magneticEventType = 106

/// The magnetometer sensor data collector.
public class TrapMagnetometerCollector: TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private var motionManager: CMMotionManager
    private let queue: OperationQueue

    /// Creates a magnetometer data collector instance.
    public init(withQueue queue: OperationQueue? = nil) {
        self.queue = queue ?? TrapSensor.queue
        motionManager = CMMotionManager()
    }

    public func checkConfiguration() -> Bool {
        let sensorOk = motionManager.isMagnetometerAvailable
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
        motionManager.magnetometerUpdateInterval = config.magnetometerSamplingRate
        motionManager.startMagnetometerUpdates(to: queue) { [weak self] data, _ in
            guard let this = self else {
                assertionFailure("Accelerometer collector empty on update")
                return
            }
            guard let magneticField = data?.magneticField else {
                assertionFailure("Magnetometer data was empty")
                return
            }

            let timestamp = TrapTime.normalizeTime(data?.timestamp ?? 0)
            this.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(magneticEventType), // Event type
                DataType.int64(timestamp), // Timestamp
                DataType.double(Double(magneticField.x)), // X direction
                DataType.double(Double(magneticField.y)), // Y direction
                DataType.double(Double(magneticField.z)) // Z direction
            ]))
        }
    }

    public func stop() {
        motionManager.stopMagnetometerUpdates()
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapMagnetometerCollector()
    }
}
