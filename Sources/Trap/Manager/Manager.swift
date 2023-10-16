import UIKit

let startEventType = 130

let stopEventType = 131

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
    private var collectors = [TrapDatasource]()

    /// Represents the common storage for all collectors
    /// and the reporter task.
    private let storage: TrapStorage

    /// Reporter instance.
    private let reporter: TrapReporter

    /// The optional colelctor operation queue.
    private let collectorQueue: OperationQueue?

    /// Create an instance of the integration module,
    /// optionally with your configuration
    public init(
        withConfig config: TrapConfig? = nil,
        withReporterQueue reporterQueue: OperationQueue? = nil,
        withCollectorQueue collectorQueue: OperationQueue? = nil
    ) throws {
        self.config = config ?? TrapConfig()
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
        collectors.append(target)

        try reporter.start()
    }

    /// Stops and removes a collector from the platform.
    public func halt(collector: TrapDatasource) {
        let id = String(describing: collector)

        collectors = collectors.filter { String(describing: $0) == id }
        collector.stop()
    }

    /// Try to run all possible collectors
    public func runAll() throws {
        let collectorQueue = OperationQueue()
        collectorQueue.name = "Trap - Collector"
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
        addStartMessage()

        try config.collectors.forEach {
            let collector = $0.instance(withConfig: config, withQueue: collectorQueue)
            if collector.checkConfiguration(), collector.checkPermission() {
                try run(collector: collector)
            }
        }
    }
    
    @objc func appMovedToForeground() {
        addStartMessage()
    }
    
    @objc func appMovedToBackground() {
        addStopMessage()
    }
    
    /// Turn off all collectors.
    public func haltAll() {
        collectors.forEach {
            halt(collector: $0)
        }
        addStopMessage()
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    /// Adds a start message signalling the start of data collection
    private func addStartMessage() {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        storage.save(sequence: timestamp, data: DataType.array([
            DataType.int(startEventType),
            DataType.int64(timestamp)
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
}
