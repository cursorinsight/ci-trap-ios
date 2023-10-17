import UIKit
import Network

let startEventType = 130

let stopEventType = 131

let customEventType = 131

/// The central place to manage the data collection integration.
/// Supports permission and configuration checks needed for
/// each data collection source, as well as enabling and disabling
/// the data sources. Once the data is collected, the module
/// serializes and sends the data to the specified endpoint.
/// There is a configurable amount of disk caching done
/// to avoid losing data due to intermittent internet disconnects.
public class TrapManager {
    /// The internal config of the entire module
    private let config: TrapConfig

    /// The collector data sources which are enabled
    private var collectors = [String: TrapDatasource]()

    /// Represents the common storage for all collectors
    /// and the reporter task.
    private let storage: TrapStorage

    /// Reporter instance.
    private let reporter: TrapReporter

    /// The optional colelctor operation queue.
    private let collectorQueue: OperationQueue?

    private var networkMonitor: NWPathMonitor?

    /// Is in low data mode
    private var inLowDataMode: Bool = false

    /// Has low battery
    private var hasLowBattery: Bool = false

    // Currently used data collection config
    private var currentDataCollectionConfig : TrapConfig.DataCollection

    /// Create an instance of the integration module,
    /// optionally with your configuration
    public init(
        withConfig config: TrapConfig? = nil,
        withReporterQueue reporterQueue: OperationQueue? = nil,
        withCollectorQueue collectorQueue: OperationQueue? = nil
    ) throws {
        self.config = config ?? TrapConfig()
        self.currentDataCollectionConfig = config?.defaultDataCollection ?? TrapConfig().defaultDataCollection
        self.collectorQueue = collectorQueue
        storage = TrapStorage(withConfig: config)

        let reporterQueue = reporterQueue ?? {
            let queue = OperationQueue()
            queue.qualityOfService = .background

            return queue
        }()
        reporterQueue.maxConcurrentOperationCount = 1
        reporter = TrapReporter(reporterQueue, storage, self.config)
    }

    // Turn off any running collectors at the
    // point of deinitialization of the manager
    // instance.
    deinit {
        haltAll()
    }

    /// Adds a collector instance to the platform and
    /// starts it immediately.
    public func run(collector: TrapDatasource) throws {
        var target = collector

        target.delegate = storage
        target.start()
        collectors[String(reflecting: type(of: target))] = target
        try reporter.start()
    }

    /// Stops and removes a collector from the platform.
    public func halt(collector: TrapDatasource) {
        let key = String(reflecting: type(of: collector))
        guard let existingCollector = collectors[key] else { return }
        collectors.removeValue(forKey: key)
        collector.stop()
    }

    /// Try to run all possible collectors
    public func runAll() throws {
        let collectorQueue = OperationQueue()
        collectorQueue.name = "Trap - Collector"

        subscribeOnNotifications()
        addStartMessage()

        currentDataCollectionConfig = getDataCollectionConfig()

        try currentDataCollectionConfig.collectors.forEach {
            if let collectorType = (NSClassFromString($0) as? TrapDatasource.Type) {
                let collector = collectorType.instance(
                    withConfig: currentDataCollectionConfig,
                    withQueue: collectorQueue)
                if collector.checkConfiguration(), collector.checkPermission() {
                    try run(collector: collector)
                }
            }
        }
    }

    /// Turn off all collectors.
    public func haltAll() {
        collectors.values.forEach {
            halt(collector: $0)
        }
        addStopMessage()
        unsubscribeFromNotifications()
    }

    private func unsubscribeFromNotifications() {
        networkMonitor?.cancel()
        networkMonitor = nil

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil)

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

    private func subscribeOnNotifications() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = networkChanged
        networkMonitor?.start(queue: DispatchQueue(label: "Monitor"))

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    public func addCustomMetadata(key: String, value: String) {
        let metaCollectorKey = String(reflecting: TrapMetadataCollector.self)
        guard let metadataCollector = (collectors[metaCollectorKey] as? TrapMetadataCollector) else { return }
        metadataCollector.addCustom(key: key, value: value)
    }

    public func removeCustomMetadata(key: String) {
        let metaCollectorKey = String(reflecting: TrapMetadataCollector.self)
        guard let metadataCollector = (collectors[metaCollectorKey] as? TrapMetadataCollector) else { return }
        metadataCollector.removeCustom(key: key)
    }

    public func addCustomEvent(custom: DataType) {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        storage.save(sequence: timestamp, data: DataType.array([
            DataType.int(customEventType),
            DataType.int64(timestamp),
            custom
        ]))
    }

    /// Adds a start message signalling the start of data collection
    private func addStartMessage() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        storage.save(sequence: timestamp, data: DataType.array([
            DataType.int(startEventType),
            DataType.int64(timestamp),
            DataType.bool(inLowDataMode),
            DataType.bool(hasLowBattery)
        ]))
    }

    /// Adds a stop message signalling the end of data collection
    private func addStopMessage() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        storage.save(sequence: timestamp, data: DataType.array([
            DataType.int(stopEventType),
            DataType.int64(timestamp)
        ]))
    }

    private func networkChanged(path: NWPath){
        self.inLowDataMode = path.isConstrained || path.isExpensive
        maybeModifyConfigAndRestartCollection()
    }

    @objc func batteryDidChange(_ notification: Notification) {
        self.hasLowBattery =
            (UIDevice.current.batteryState == .unplugged || UIDevice.current.batteryState == .unknown) &&
            UIDevice.current.batteryLevel < config.lowBatteryThreshold &&
            UIDevice.current.batteryLevel >= 0
        maybeModifyConfigAndRestartCollection()

        let batteryCollectorKey = String(reflecting: TrapBatteryCollector.self)
        guard let batteryCollector = (collectors[batteryCollectorKey] as? TrapBatteryCollector) else { return }
        batteryCollector.sendBatteryEvent()
    }

    private func maybeModifyConfigAndRestartCollection() {
        if (getDataCollectionConfig() != currentDataCollectionConfig) {
            haltAll()
            do {
                try runAll()
            } catch {
                print("Could not restart collectors")
            }
        }
    }

    private func getDataCollectionConfig() -> TrapConfig.DataCollection {
        if (inLowDataMode) {
            return config.lowDataDataCollection
        }
        if (hasLowBattery) {
            return config.lowBatteryDataCollection
        }
        return config.defaultDataCollection
    }

    @objc func appMovedToForeground() {
        addStartMessage()
    }

    @objc func appMovedToBackground() {
        addStopMessage()
    }
}
