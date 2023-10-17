import UIKit

/// The protocol describing a data source collector which
/// can be added to the platform and it's lifecycle tracked.
public protocol TrapDatasource {
    var delegate: TrapDatasourceDelegate? { get set }

    /// Checks if the app configuration is properly set up properly.
    func checkConfiguration() -> Bool

    /// Check if the runtime permission for the particular
    /// data source is provided by the user.
    func checkPermission() -> Bool

    /// Ask the user for the appropriate runtime permission
    /// needed for this collector.
    func requestPermission(_ success: @escaping () -> Void)

    /// Start the data collection process for this particular collector.
    func start(withConfig: TrapConfig.DataCollection)

    /// Stop the data collection process for this particular collector.
    func stop()

    /// Create a new instance of this datasource.
    static func instance(withQueue: OperationQueue) -> TrapDatasource
}

/// The data source delegate which abstracts away data frame storage.
/// @mockable
public protocol TrapDatasourceDelegate {
    /// Save a data frame with a unique sequence number used for
    /// soring frames withing a data packet.
    func save(sequence: Int64, data: DataType)
}

/// Data serialization helper.
public enum DataType: Encodable {
    case string(String)
    case int(Int)
    case int64(Int64)
    case float(Float)
    case double(Double)
    case bool(Bool)
    case array([DataType])
    case uint64(UInt64)
    case dict([String: DataType])

    /// Encodes a native swift data structure into a serialized one.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(item):
            try container.encode(item)
        case let .int(item):
            try container.encode(item)
        case let .int64(item):
            try container.encode(item)
        case let .uint64(item):
            try container.encode(item)
        case let .float(item):
            try container.encode(item)
        case let .double(item):
            try container.encode(item)
        case let .bool(item):
            try container.encode(item)
        case let .array(item):
            try item.encode(to: encoder)
        case let .dict(item):
            try item.encode(to: encoder)
        }
    }
}
