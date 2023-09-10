@testable import Trap
import UIKit
import XCTest

final class GestureTests: XCTestCase {
    override func setUp() {
        UIWindow.enableMock()
    }
    
    override func tearDown() {
        UIWindow.disableMock()
    }
    
    func testTouch() throws {
        let sendsCompleted = [
            "[100,\(TrapTime.normalizeTime(1.0)),0,1,2,-1,-2]": expectation(description: "Start"),
            "[101,\(TrapTime.normalizeTime(3.0)),0,3,4,-3,-4]": expectation(description: "Move"),
            "[102,\(TrapTime.normalizeTime(5.0)),0,5,6,-5,-6]": expectation(description: "End")
        ]
        
        let collector = TrapTouchCollector()
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard let json = try? JSONEncoder().encode(data), let output = String(data: json, encoding: .utf8) else {
                return
            }
            
            let expect = sendsCompleted[output]
            XCTAssertNotNil(expect, "Expected one of three types of data frame")
            expect?.fulfill();
        }
        collector.delegate = delegate
        collector.start()
        
        let window = UIWindow(frame: CGRect.zero)
        NotificationCenter.default.post(name: UIWindow.didBecomeVisibleNotification, object: window)
        
        // UIEvent and UITouch MUST be reused across this test!
        let touch = UITouchMock()
        touch._type = .direct
        touch._timestamp = 1.0
        touch._location = CGPoint(x: 1.0, y: 2.0)
        touch._force = -1.0
        touch._majorRadius = -2.0
        let event = UIEventMock()
        
        // BEGIN
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        // MOVE
        touch._timestamp = 3.0
        touch._location = CGPoint(x: 3.0, y: 4.0)
        touch._force = -3.0
        touch._majorRadius = -4.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesMoved(Set(event._touches!), with: event)
        }
        
        // END
        touch._type = .direct
        touch._timestamp = 5.0
        touch._location = CGPoint(x: 5.0, y: 6.0)
        touch._force = -5.0
        touch._majorRadius = -6.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesEnded(Set(event._touches!), with: event)
        }
        
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        
        NotificationCenter.default.post(name: UIWindow.didBecomeHiddenNotification, object: window)
        
        touch._type = .direct
        touch._timestamp = 11.0
        touch._location = CGPoint(x: 12.0, y: 13.0)
        touch._force = 14.0
        touch._majorRadius = 15.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        collector.stop()
        
        
    }
}
