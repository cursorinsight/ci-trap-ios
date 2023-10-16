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
public struct TrapConfig {
    /// The data frame collector ring queue size
    public var queueSize: Int

    public var lowBatteryThreshold: Float
    
    /// The configuration for the reporter task.
    public var reporter: Reporter

    public var defaultDataCollection: DataCollection

    public var lowBatteryDataCollection: DataCollection

    public var lowDataDataCollection: DataCollection

    // MARK: - The subconfigurations

    public struct DataCollection : Equatable {
        /// The default collectors to run with `runAll()`
        public var collectors: [TrapDatasource.Type]

        /// Should gesture recognizers be used for touch event collection
        public var useGestureRecognizer: Bool

        /// How frequent the sampling of the given sensor should be.
        public var accelerationSamplingRate: TimeInterval

        /// How frequent the sampling of the given sensor should be.
        public var gyroscopeSamplingRate: TimeInterval

        /// How frequent the sampling of the given sensor should be.
        public var magnetometerSamplingRate: TimeInterval

        /// How frequent the sampling of the given sensor should be.
        public var gravitySamplingRate: TimeInterval

        /// Collect coalesced pointer events
        public var collectCoalescedPointerEvents: Bool

        /// Collect coalesced stylus events
        public var collectCoalescedStylusEvents: Bool

        /// Collect coalesced touch events
        public var collectCoalescedTouchEvents: Bool

        public init() {
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
                TrapWiFiCollector.self,
                TrapBatteryCollector.self
            ]
            useGestureRecognizer = true
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

            collectCoalescedPointerEvents = true
            collectCoalescedStylusEvents = true
            collectCoalescedTouchEvents = true
        }
        
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.collectCoalescedPointerEvents == rhs.collectCoalescedPointerEvents &&
            lhs.collectCoalescedStylusEvents == rhs.collectCoalescedStylusEvents &&
            lhs.collectCoalescedTouchEvents == rhs.collectCoalescedTouchEvents &&
            lhs.useGestureRecognizer == rhs.useGestureRecognizer &&
            lhs.accelerationSamplingRate == rhs.accelerationSamplingRate &&
            lhs.gyroscopeSamplingRate == rhs.gyroscopeSamplingRate &&
            lhs.gravitySamplingRate == rhs.gravitySamplingRate &&
            lhs.magnetometerSamplingRate == rhs.magnetometerSamplingRate &&
            lhs.collectors.elementsEqual(rhs.collectors, by: { firstType, secondType in
                return String(describing: firstType) == String(describing: secondType)
            })
        }
        
    }

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

        /// Compress data sent to server
        public var compressed: Bool

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
            compressed = false
        }
    }

    /// Create a default configuration instance ready to be used.
    public init() {
        queueSize = 2048
        lowBatteryThreshold = 0.1
        
        reporter = Reporter()
        defaultDataCollection = DataCollection()
        lowBatteryDataCollection = DataCollection()
        lowBatteryDataCollection.collectors = [
            TrapLocationCollector.self,
            TrapStylusCollector.self,
            TrapTouchCollector.self,
            TrapBatteryCollector.self,
        ]
        if #available(iOS 13.4, *) {
            lowBatteryDataCollection.collectors.append(TrapPointerCollector.self)
        }
     
        lowBatteryDataCollection.collectCoalescedPointerEvents = false
        lowBatteryDataCollection.collectCoalescedStylusEvents = false
        lowBatteryDataCollection.collectCoalescedTouchEvents = false

        lowDataDataCollection = DataCollection()
        lowDataDataCollection.collectors = [
            TrapLocationCollector.self,
            TrapStylusCollector.self,
            TrapTouchCollector.self,
            TrapBatteryCollector.self,
        ]
        if #available(iOS 13.4, *) {
            lowDataDataCollection.collectors.append(TrapPointerCollector.self)
        }
        lowDataDataCollection.collectCoalescedPointerEvents = false
        lowDataDataCollection.collectCoalescedStylusEvents = false
        lowDataDataCollection.collectCoalescedTouchEvents = false
    }

}
