@testable import Trap
import Foundation
import XCTest

class FileCacheTests: XCTestCase {
    
    override func tearDown() {
        let cache = TrapFileCache(maxSize: 1024)!
        try! cache.clear()
    }
    
    func testStoreRetrieve() {
        let cache = TrapFileCache(maxSize: 1024)!
        try! cache.push(data: "This is a test")
        let data = try! cache.getAll()
        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(try! data.first?.content(), "This is a test")
    }
    
    func testOverCapacity() {
        let cache = TrapFileCache(maxSize: 256)!
        try! cache.push(data: "This is a test This is a test 1")
        try! cache.push(data: "This is a test This is a test 2")
        try! cache.push(data: "This is a test This is a test 3")
        try! cache.push(data: "This is a test This is a test 4")
        try! cache.push(data: "This is a test This is a test 5")
        try! cache.push(data: "This is a test This is a test 6")
        try! cache.push(data: "This is a test This is a test 7")
        try! cache.push(data: "This is a test This is a test 8")
        try! cache.push(data: "This is a test This is a test 9")
        try! cache.push(data: "This is a test This is a test 10")
        let data = try! cache.getAll()
        XCTAssertEqual(data.count, 9)
    }
}
