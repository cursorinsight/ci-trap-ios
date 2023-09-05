import Dispatch

/// A 'ring queue' (also called 'circular buffer') is a data structure that
/// uses a single, fixed-size buffer as if it were connected end-to-end
/// to implement a First-In-Last-Out bounded 'pipe'. This structure lends
/// itself easily to buffering data streams.
struct RingQueue<T> {
    /*
       RING BUFFER OF SIZE 3
       +---+   +---+   +---+
       | 1 |-->| 2 |-->| 3 |
       +---+   +---+   +---+
       ^               |
       |               |
       +---------------+

     Implementation notes: The ring queue is backed by a swift array with
     the *at least* the capacity indicated. At the time of the creation of this
     lib, there is no dynamically configurable fixed size array type in Swift,
     so we live with a little overhead in memory for every buffer.

     The usage pattern for this data structure is sequential single push and
     periodic batched dequeue of all current items in the queue. The ring
     behavior is implemented somewhat differently from typical ring queue
     implementations. The data structure tracks an element `count` value and
     an write index, where the next push operation will deposit the data.

     When the buffer gets filled up, the head index will resets back to index '0'
     and starts to override the oldest records. When eventually the data gets
     dequeued, the head index will not change, but the count value will be set
     to '0'. The data dequeued comes from at most two parts of the buffer.
     First all the records from 0..head if count > head, then the remainder of
     abs(head -  count) from the end of the array. If count <= head, then
     (head-count)..<head is returned.
     */

    /**
     The maximum capacity of the ring queue. This needs to be stored
     separately, because the backing buffer's capacity will automatically
     gets bumped the moment you get near the indicated capacity.
     */
    public let capacity: Int

    /**
     The amount of records currently stored in this buffer. This is also
     the value we use to calculate range operations.
     */
    private(set) var count: Int

    /*
     Stores the index on buffer where the next push
     (enqueue) operation will write.
     */
    private var idx: Int

    /*
     The backing buffer actually storing the data in the collection.
     */
    private var buffer: [T?]

    /**
     Creates a new, empty ring buffer having the exact capacity specified.
     */
    public init(withCapacity capacity: Int = 1024) {
        self.capacity = capacity
        count = 0
        idx = 0
        buffer = Array(repeating: nil, count: capacity)
    }

    /**
     Resets this ring buffer instance to empty.
     */
    mutating func removeAll() {
        count = 0
    }

    // MARK: - Queue protocol implementation

    /**
     Returns true if the ring buffer is currently empty
     */
    var isEmpty: Bool {
        count == 0
    }

    /*
     * Enqueues a new item, possibly overriding
     * the oldest item in the queue.
     */
    mutating func enqueue(_ item: T) {
        buffer[idx] = item

        // If idx would grow larger than allowed capacity
        // start over from idx = 0
        idx = (idx + 1) % capacity

        if count < capacity {
            // Only bunp count if there is still space to grow
            // otherwise the count will be equal to capacity
            // until the user dequeues elements
            count += 1
        }
    }

    /*
     Dequeues the oldest item if the queue is not empty.
     */
    mutating func dequeue() -> T? {
        guard count > 0 else {
            // If the queue is empty there is nothing to return
            return nil
        }

        let oldest = idx - count < 0
            // The oldest items are ahead of idx
            ? capacity + idx - count
            // The oldest item is behind d
            : idx - count
        let item = buffer[oldest]
        count -= 1

        return item
    }

    /**
     Remove all the items from the queue, reset the queue
     to empty and return the data as an array
     */
    mutating func takeAll() -> [T] {
        var result = [T]()

        result.reserveCapacity(count)

        if idx - count < 0 {
            // The oldest item is ahead of idx
            let pos = capacity + idx - count

            // Copy the first half of the data from the end of the
            // backing array
            buffer[pos ..< capacity].forEach { item in
                result.append(item!)
            }

            // Copy the last half of the data from the beginning
            // of the backing array
            buffer[0 ..< idx].forEach { item in
                result.append(item!)
            }
        } else {
            // The oldest item is behind idx
            let pos = idx - count

            // Copy the contiguous array slice over
            // and we're done
            buffer[pos ..< idx].forEach { item in
                result.append(item!)
            }
        }

        // Reset the queue
        count = 0

        return result
    }
}
