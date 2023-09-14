@testable import Trap
import Foundation

class MockStorage: TrapStorage {
    var makeIteratorCalled: (() -> Void)?
    private var storage: ConcurrentRingQueue<(Int64, DataType)> {
        get {
            let storage = ConcurrentRingQueue<(Int64, DataType)>(withCapacity: 1024)
            storage.enqueue((1, DataType.array([DataType.int(999), DataType.int64(Int64(Date().timeIntervalSince1970))])))
            return storage
        }
    }
    
    override func makeIterator() -> TrapDatasourceIterator {
        makeIteratorCalled?()
        return TrapDatasourceIterator(storage, TrapConfig())
    }
}
