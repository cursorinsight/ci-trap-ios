import UIKit

/// Represents the common storage for all collectors.
class TrapStorage: TrapDatasourceDelegate, Sequence {
    /// The lib configuration.
    private let config: Config

    /// The common storage for all collectors.
    private let storage: ConcurrentRingQueue<(Int64, DataType)>

    /// Create a new lib common storage instance.
    public init(withConfig config: Config?) {
        self.config = config ?? Config()
        storage = ConcurrentRingQueue(withCapacity: self.config.queueSize)
    }

    public func save(sequence: Int64, data: DataType) {
        storage.enqueue((sequence, data))
    }

    func makeIterator() -> TrapDatasourceIterator {
        TrapDatasourceIterator(storage, config)
    }
}

/// The iterator for data packet creation.
class TrapDatasourceIterator: IteratorProtocol {
    let storage: ConcurrentRingQueue<(Int64, DataType)>

    /// Create new instance of the storage iterator.
    public init(_ storage: ConcurrentRingQueue<(Int64, DataType)>, _: Config) {
        self.storage = storage
    }

    func next() -> (Int64, DataType)? {
        storage.dequeue()
    }
}
