import Foundation

/// The configuration of the data collection system happens
/// via this struct. Use the default configuration or change
/// parameters to fine tune the collection system to your needs.
///
/// ## Customization
///
///  You can customize parts of the default configuration like this:
///
/// ```swift
/// import Trap
///
/// @main
/// struct MyApp: App {
///     let trapManager: TrapManager
///
///      public init() {
///          let config = Config()
///
///          // Modify the fields directly
///          config.reportingInterval = .seconds(1)
///          trapManager = TrapManager(withConfig: config)
///      }
/// }
/// ```
public struct Config {
    /// The data frame collector ring queue size
    public var queueSize: Int

    /// The configuration for the reporter task.
    public var reporter: Reporter

    /// The default collectors to run with `runAll()`
    public var collectors: [TrapDatasource.Type]

    /// How frequent the sampling of the given sensor should be.
    public var accelerationSamplingRate: TimeInterval

    /// How frequent the sampling of the given sensor should be.
    public var gyroscopeSamplingRate: TimeInterval

    /// How frequent the sampling of the given sensor should be.
    public var magnetometerSamplingRate: TimeInterval

    /// How frequent the sampling of the given sensor should be.
    public var gravitySamplingRate: TimeInterval

    // MARK: - The subconfigurations

    /// The configuration for the reporter task serializing
    /// and sending the collected data through the transport.
    public struct Reporter {
        /// Whether to cache data packets on the device
        /// when conntection to the remote server cannot be
        /// established.
        public var cachedTransport: Bool

        /// About how much space on the device can be
        /// used to store unsent data packets.
        ///
        /// The lib might use a little more space than this
        /// value in case the data packet size exceeds the
        /// remaining space.
        public var maxFileCacheSize: UInt64

        /// The time interval the reporter task runs with.
        public var interval: OperationQueue.SchedulerTimeType.Stride

        /// The endpoint where the collected data is transmitted to.
        public var url: String

        /// The session ID parameter in the data format. Usually persistent
        /// across app launches.
        public var sessionId: UUID

        public init() {
            cachedTransport = true
            maxFileCacheSize = 5_000_000
            interval = .seconds(1)
            url = "https://example.com/api/post/{streamId}/{sessionId}"
            sessionId = {
                let defaults = UserDefaults()

                let userId = defaults.string(forKey: "__trap_userId") ?? {
                    let userId = UUID().uuidString
                    defaults.set(userId, forKey: "__trap_userId")

                    return userId
                }()

                return UUID(uuidString: userId)!
            }()
        }
    }

    /// Create a default configuration instance ready to be used.
    public init() {
        queueSize = 2048
        reporter = Reporter()
        collectors = [
            TrapAccelerometerCollector.self,
            TrapGravityCollector.self,
            TrapGyroscopeCollector.self,
            TrapLocationCollector.self,
            TrapMagnetometerCollector.self,
            TrapPinchCollector.self,
            TrapStylusCollector.self,
            TrapSwipeCollector.self,
            TrapTapCollector.self,
            TrapTouchCollector.self,
            TrapWiFiCollector.self
        ]
        if #available(iOS 13.1, *) {
            collectors.append(TrapBluetoothCollector.self)
        }
        if #available(iOS 13.4, *) {
            collectors.append(TrapPointerCollector.self)
        }
        accelerationSamplingRate = 1.0 / 60.0 // 60 Hz
        gyroscopeSamplingRate = 1.0 / 60.0 // 60 Hz
        magnetometerSamplingRate = 1.0 / 60.0 // 60 Hz
        gravitySamplingRate = 1.0 / 60.0 // 60 Hz
    }
}
