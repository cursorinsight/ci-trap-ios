import Combine
import UIKit

/// The transport type is not supported.
class TransportSchemeError: Error {}

/// Thrown when the url cannot be parsed
class TransportURLError: Error {}

/// The reporter task.
class TrapReporter {
    /// This is the operation queue we use to run the
    /// endlessly repeating reporter task.
    private let queue: OperationQueue

    /// A holder for the cancelable operation
    /// for the repeating reporting task
    private var reporterTask: Cancellable?

    /// The transport mechanism to send the data through
    private var transport: TrapTransport?

    /// The common data storage class instance
    private let storage: TrapStorage

    /// The endpoint of the reporter to use
    private let config: TrapConfig

    /// The streamId of this continuous data stream.
    private var streamId = UUID()

    /// The data packet sequence id.
    private var sequenceId = 0

    /// Create the reporting task.
    public init(
        _ queue: OperationQueue,
        _ storage: TrapStorage,
        _ config: TrapConfig
    ) {
        self.queue = queue
        self.storage = storage
        self.config = config
        self.transport = nil
    }

    deinit {
        stop()
    }

    /// Starts the reporting task.
    func start(avoidSendingTooMuchData: Bool = false) throws {
        guard reporterTask == nil else { return }

        streamId = UUID()

        let urlString = config.reporter.url
            .replacingOccurrences(of: "{sessionId}", with: config.reporter.sessionId.uuidString)
            .replacingOccurrences(of: "{streamId}", with: streamId.uuidString)
        guard let url = URL(string: urlString) else { throw TransportURLError() }

        // Initialize the transport system.
        let connection: TrapTransport? = {
            switch url.scheme {
            case "ws", "wss":
                return TrapWSKeepaliveForegroundTransport(url, config.reporter)
            case "http", "https":
                return TrapHttpTransport(url, config.reporter)
            default:
                return nil
            }
        }()
        guard let conn = connection else {
            throw TransportSchemeError()
        }
        if config.reporter.cachedTransport {
            transport = TrapCachedTransport(with: conn)
        } else {
            transport = conn
        }
        transport?.start()

        let encoder = JSONEncoder()

        reporterTask = queue.schedule(
            after: .init(Date(timeIntervalSinceNow: 1)),
            interval: config.reporter.interval
        ) { [weak self] in
            guard let this = self else {
                assertionFailure("Manager reporter task becomes empty while running")
                return
            }
            let group = DispatchGroup()
            group.enter()
            
            let data = this.storage
                .sorted { $0.0 < $1.0 }
                .map(\.1)

            guard !data.isEmpty else { return }

            let json = try? data.map { try encoder.encode($0) }
                .map { String(data: $0, encoding: .utf8)! }
                .joined(separator: ",\n")

            guard let encoded = json else { return }

            let packet = [
                String(data: try! encoder.encode(this.getHeader()), encoding: .utf8)!,
                encoded
            ].joined(separator: ",\n")

            this.transport?.send(
                data: "[\n" + packet + "\n]",
                avoidSendingTooMuchData: avoidSendingTooMuchData
            ) { error in
                group.leave()
                if let _ = error {
                    debugPrint("Failed to send or cache packet")
                }
            }
            group.wait()
        }
    }

    /// Stop the reporting task.
    func stop() {
        reporterTask?.cancel()
        transport?.stop()
    }

    /// Creates the header for transport.
    public func getHeader() -> DataType {
        let headerEventType = -1
        let timestamp = TrapTime.getCurrentTime()
        let header = DataType.array([
            DataType.int(headerEventType),
            DataType.int64(timestamp),
            DataType.string(config.reporter.sessionId.uuidString),
            DataType.string(streamId.uuidString),
            DataType.int(sequenceId),
            DataType.dict(["version": DataType.string("20230706T094422Z")]),
            DataType.string(Constants.App.version)
        ])

        sequenceId += 1

        return header
    }
}
