import UIKit

/// The central place to manage the data collection integration.
/// Supports permission and configuration checks needed for
/// each data collection source, as well as enabling and disabling
/// the data sources. Once the data is collected, the module
/// serializes and sends the data to the specified endpoint.
/// There is a configurable amount of disk caching done
/// to avoid losing data due to intermittent internet disconnects.
public class TrapManager {
    /// The internal config of the entire module
    private let config: Config

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
        withConfig config: Config? = nil,
        withReporterQueue reporterQueue: OperationQueue? = nil,
        withCollectorQueue collectorQueue: OperationQueue? = nil
    ) throws {
        self.config = config ?? Config()
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

        try config.collectors.forEach {
            let collector = $0.instance(withConfig: config, withQueue: collectorQueue)
            if collector.checkConfiguration(), collector.checkPermission() {
                try run(collector: collector)
            }
        }
    }

    /// Turn off all collectors.
    public func haltAll() {
        collectors.forEach {
            halt(collector: $0)
        }
    }
}
