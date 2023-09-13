@testable import Trap
import XCTest

class StorageTests: XCTestCase {
    func testStoreRetrieve() {
        let storage = TrapStorage(withConfig: TrapConfig())
        storage.save(sequence: 1, data: DataType.int(1))
        let iter = storage.makeIterator()
        let (sequ, record) = iter.next()!
        guard case let DataType.int(value) = record else {
            XCTFail("Wrong data type returned by iterator")
            return
        }
        XCTAssertEqual(sequ, 1)
        XCTAssertEqual(value, 1)
    }
}
