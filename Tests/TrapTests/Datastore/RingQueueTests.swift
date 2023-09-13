@testable import Trap
import XCTest

final class RingQueueTests: XCTestCase {
    private var queue: ConcurrentRingQueue<Int> = ConcurrentRingQueue(withCapacity: 3)

    override func setUp() {
        queue.removeAll()
    }

    func testEnqueue() {
        queue.enqueue(1)
        XCTAssertEqual(1, queue.count)
    }

    func testRemoveAll() {
        queue.enqueue(987)
        queue.enqueue(675)
        XCTAssertEqual(2, queue.count)
        queue.removeAll()
        XCTAssertEqual(0, queue.count)
    }

    func testDequeuesWhatWasEnqueued() {
        queue.enqueue(987)
        XCTAssertEqual(987, queue.dequeue())
    }

    func testEnqueueOverCapacity() {
        queue.enqueue(987)
        queue.enqueue(675)
        queue.enqueue(435)
        queue.enqueue(214)
        XCTAssertEqual(3, queue.count)
    }

    func testDequeuesOldestWithinCapacity() {
        queue.enqueue(987)
        queue.enqueue(675)
        queue.enqueue(435)
        queue.enqueue(214)
        XCTAssertEqual(675, queue.dequeue())
        XCTAssertEqual(435, queue.dequeue())
        XCTAssertEqual(214, queue.dequeue())
    }

    func testTakeAllLessThanFull() {
        queue.enqueue(987)
        queue.enqueue(675)
        XCTAssertEqual([987, 675], queue.takeAll())
        XCTAssertEqual(0, queue.count)
    }

    func testTakeAllWhileBeingFull() {
        queue.enqueue(987)
        queue.enqueue(675)
        queue.enqueue(435)
        queue.enqueue(214)
        XCTAssertEqual([675, 435, 214], queue.takeAll())
        XCTAssertEqual(0, queue.count)
    }

    func testTakeAllWithOnceFullQueue() {
        queue.enqueue(987)
        queue.enqueue(675)
        queue.enqueue(435)
        queue.enqueue(214)
        XCTAssertEqual(675, queue.dequeue())
        XCTAssertEqual([435, 214], queue.takeAll())
    }
}
