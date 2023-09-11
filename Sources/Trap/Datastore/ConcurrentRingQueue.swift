import Dispatch

/**

 */
class ConcurrentRingQueue<T> {
    /// The underlying non-concurrent ring queue.
    private var queue: RingQueue<T>

    /// The serial dispatch queue for managing concurrency.
    private var dispatcher: DispatchQueue
    
    var count: Int {
        get {
            return queue.count
        }
    }

    /// Create a concurrent version of the RingQueue instance.
    public init(withCapacity: Int = 1024) {
        queue = RingQueue(withCapacity: withCapacity)
        dispatcher = DispatchQueue(
            label: "Trap - RingQueue",
            target: .global(qos: .default)
        )
    }

    /// Places an item in the ring queue in a thread-safe way.
    public func enqueue(_ value: T) {
        dispatcher.sync {
            queue.enqueue(value)
        }
    }

    /// Removes the oldest element from the ring queue
    /// in a thread-safe way.
    public func dequeue() -> T? {
        var value: T?

        dispatcher.sync {
            value = queue.dequeue()
        }

        return value
    }

    /// Removes all the elements from the ring queue
    /// and returns them in a thread-safe way.
    public func takeAll() -> [T] {
        var result = [T]()

        dispatcher.sync {
            result = queue.takeAll()
        }

        return result
    }
    
    /// Clean the ring queue
    public func removeAll() {
        dispatcher.sync {
            queue.removeAll()
        }
    }
}
