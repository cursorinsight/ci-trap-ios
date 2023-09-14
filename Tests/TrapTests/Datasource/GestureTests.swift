@testable import Trap
import UIKit
import XCTest

final class GestureTests: XCTestCase {
    override func setUp() {
        UIWindow.enableMock()
        UITapGestureRecognizer.enableMock()
        UISwipeGestureRecognizer.enableMock()
        UIPinchGestureRecognizer.enableMock()
    }
    
    override func tearDown() {
        UIWindow.disableMock()
        UITapGestureRecognizer.disableMock()
        UISwipeGestureRecognizer.disableMock()
        UIPinchGestureRecognizer.disableMock()
    }
    
    func testTouch() throws {
        let sendsCompleted = [
            "[100,\(TrapTime.normalizeTime(1.0)),0,1,2,-1,-2]": expectation(description: "Start"),
            "[101,\(TrapTime.normalizeTime(3.0)),0,3,4,-3,-4]": expectation(description: "Move"),
            "[102,\(TrapTime.normalizeTime(5.0)),0,5,6,-5,-6]": expectation(description: "End"),
            "[100,\(TrapTime.normalizeTime(21.0)),0,22,23,24,25]": expectation(description: "Start Again"),
            "[102,\(TrapTime.normalizeTime(31.0)),0,32,33,34,35]": expectation(description: "Cancel"),
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
        
        // CANCEL
        touch._type = .direct
        touch._timestamp = 21.0
        touch._location = CGPoint(x: 22.0, y: 23.0)
        touch._force = 24.0
        touch._majorRadius = 25.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }

        touch._type = .direct
        touch._timestamp = 31.0
        touch._location = CGPoint(x: 32.0, y: 33.0)
        touch._force = 34.0
        touch._majorRadius = 35.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesCancelled(Set(event._touches!), with: event)
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
        
        XCTAssertNotNil(TrapTouchCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
        XCTAssertNotNil(collector.createRecongizers(UIWindow(frame: CGRect.zero)))
        
        collector.stop()
    }
    
    @available(iOS 13.4, *)
    func testPointer() throws {
        let sendsCompleted = [
            "[5,\(TrapTime.normalizeTime(1.0)),1,2,0]": expectation(description: "Start"),
            "[0,\(TrapTime.normalizeTime(3.0)),3,4,0]": expectation(description: "Move"),
            "[6,\(TrapTime.normalizeTime(5.0)),5,6,0]": expectation(description: "End"),
            "[5,\(TrapTime.normalizeTime(21.0)),22,23,1]": expectation(description: "Start Again"),
            "[6,\(TrapTime.normalizeTime(31.0)),32,33,1]": expectation(description: "Cancel")
        ]
        
        let collector = TrapPointerCollector()
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
        touch._type = .indirectPointer
        touch._timestamp = 1.0
        touch._location = CGPoint(x: 1.0, y: 2.0)
        let event = UIEventMock()
        event._buttonMask = 0
        
        // BEGIN
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        // MOVE
        touch._timestamp = 3.0
        touch._location = CGPoint(x: 3.0, y: 4.0)
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesMoved(Set(event._touches!), with: event)
        }
        
        // END
        touch._timestamp = 5.0
        touch._location = CGPoint(x: 5.0, y: 6.0)
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesEnded(Set(event._touches!), with: event)
        }
        
        // CANCEL
        touch._timestamp = 21.0
        touch._location = CGPoint(x: 22.0, y: 23.0)
        event._touches = [touch]
        event._buttonMask = 1
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }

        touch._timestamp = 31.0
        touch._location = CGPoint(x: 32.0, y: 33.0)
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesCancelled(Set(event._touches!), with: event)
        }
        
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        
        NotificationCenter.default.post(name: UIWindow.didBecomeHiddenNotification, object: window)
        
        touch._type = .direct
        touch._timestamp = 11.0
        touch._location = CGPoint(x: 12.0, y: 13.0)
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        collector.stop()
        
        let delegate2 = TrapDatasourceDelegateMock()
        delegate2.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data else {
                return
            }
            guard case let DataType.int(eventType) = frame[0] else {
                return
            }
            guard case let DataType.double(x) = frame[2] else {
                return
            }
            guard case let DataType.double(y) = frame[3] else {
                return
            }
            XCTAssertEqual(eventType, 0)
            XCTAssertEqual(x, 42.0)
            XCTAssertEqual(y, 43.0)
        }
        collector.delegate = delegate2
        
        let hover = UIHoverGestureRecognizerMock()
        hover._location = CGPoint(x: 42.0, y: 43.0)
        collector.handleHover(hover)
        
        XCTAssertNotNil(TrapPointerCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
    }
    
    func testStylus() throws {
        let sendsCompleted = [
            "[110,\(TrapTime.normalizeTime(1.0)),1,2,3,4,5]": expectation(description: "Start"),
            "[111,\(TrapTime.normalizeTime(3.0)),6,7,8,9,10]": expectation(description: "Move"),
            "[112,\(TrapTime.normalizeTime(5.0)),11,12,13,14,15]": expectation(description: "End"),
            "[110,\(TrapTime.normalizeTime(21.0)),16,17,18,19,20]": expectation(description: "Start Again"),
            "[112,\(TrapTime.normalizeTime(31.0)),21,22,23,24,25]": expectation(description: "Cancel"),
        ]
        
        let collector = TrapStylusCollector()
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
        touch._type = .pencil
        touch._timestamp = 1.0
        touch._location = CGPoint(x: 1.0, y: 2.0)
        touch._force = 3.0
        touch._altitudeAngle = 4.0
        touch._azimuthAngle = 5.0
        let event = UIEventMock()
        event._buttonMask = 0
        
        // BEGIN
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        // MOVE
        touch._timestamp = 3.0
        touch._location = CGPoint(x: 6.0, y: 7.0)
        touch._force = 8.0
        touch._altitudeAngle = 9.0
        touch._azimuthAngle = 10.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesMoved(Set(event._touches!), with: event)
        }
        
        // END
        touch._timestamp = 5.0
        touch._location = CGPoint(x: 11.0, y: 12.0)
        touch._force = 13.0
        touch._altitudeAngle = 14.0
        touch._azimuthAngle = 15.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesEnded(Set(event._touches!), with: event)
        }
        
        // CANCEL
        touch._timestamp = 21.0
        touch._location = CGPoint(x: 16.0, y: 17.0)
        touch._force = 18.0
        touch._altitudeAngle = 19.0
        touch._azimuthAngle = 20.0
        event._touches = [touch]
        event._buttonMask = 1
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }

        touch._timestamp = 31.0
        touch._location = CGPoint(x: 21.0, y: 22.0)
        touch._force = 23.0
        touch._altitudeAngle = 24.0
        touch._azimuthAngle = 25.0
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesCancelled(Set(event._touches!), with: event)
        }
        
        wait(for: sendsCompleted.values.map { $0 }, timeout: 10)
        
        NotificationCenter.default.post(name: UIWindow.didBecomeHiddenNotification, object: window)
        
        touch._type = .direct
        touch._timestamp = 11.0
        touch._location = CGPoint(x: 12.0, y: 13.0)
        event._touches = [touch]
        UIWindow.mock_recognizers.values.forEach { recognizer in
            recognizer.touchesBegan(Set(event._touches!), with: event)
        }
        
        collector.stop()
        
        XCTAssertNotNil(TrapStylusCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
    }
    
    func testTap() throws {
        let tapCalled = expectation(description: "Tap handler is called")
        let collector = TrapTapCollector()
        let recognizer = collector.createRecongizers(UIWindow(frame: CGRect.zero)).first as! UITapGestureRecognizer
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data,
                  case let DataType.int(eventType) = frame[0],
                  case let DataType.double(x) = frame[2],
                  case let DataType.double(y) = frame[3] else {
                XCTFail("Data frame is incorrect")
                return
            }
            
            XCTAssertEqual(eventType, 122)
            XCTAssertEqual(x, 35.0)
            XCTAssertEqual(y, 55.0)
            tapCalled.fulfill()
        }
        collector.delegate = delegate
        collector.start()
        collector.handleTap(sender: recognizer)
        wait(for: [tapCalled], timeout: 1)
        collector.stop()
        
        XCTAssertNotNil(TrapTapCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
    }
    
    func testSwipe() throws {
        let directionsRecognized = [
            "down": expectation(description: "Swipe down handler is called"),
            "up": expectation(description: "Swipe up handler is called"),
            "left": expectation(description: "Swipe left handler is called"),
            "right": expectation(description: "Swipe right handler is called"),
        ]
        let collector = TrapSwipeCollector()
        let recognizers = collector.createRecongizers(UIWindow(frame: CGRect.zero))
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data,
                  case let DataType.int(eventType) = frame[0],
                  case let DataType.string(direction) = frame[2] else {
                XCTFail("Data frame is incorrect")
                return
            }
            
            XCTAssertEqual(eventType, 121)
            directionsRecognized[direction]?.fulfill()
        }
        collector.delegate = delegate
        collector.start()
        let directions = [
            UISwipeGestureRecognizer.Direction.down,
            UISwipeGestureRecognizer.Direction.left,
            UISwipeGestureRecognizer.Direction.right,
            UISwipeGestureRecognizer.Direction.up
        ]
        var idx = 0
        recognizers.forEach { recognizer in
            UISwipeGestureRecognizer._direction = directions[idx]
            idx = idx + 1
            collector.handleSwipe(recognizer as! UISwipeGestureRecognizer)
        }
        
        wait(for: directionsRecognized.values.map { $0 }, timeout: 1)
        collector.stop()
        
        XCTAssertNotNil(TrapSwipeCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
    }
    
    func testPin() throws {
        let pinchCalled = expectation(description: "The pinch handler was called")
        let collector = TrapPinchCollector()
        let recognizer = collector.createRecongizers(UIWindow(frame: CGRect.zero)).first as! UIPinchGestureRecognizer
        let delegate = TrapDatasourceDelegateMock()
        delegate.saveHandler = { seq, data in
            guard case let DataType.array(frame) = data,
                  case let DataType.int(eventType) = frame[0],
                  case let DataType.double(scale) = frame[2],
                  case let DataType.double(velocity) = frame[3] else {
                XCTFail("Data frame is incorrect")
                return
            }
            
            XCTAssertEqual(eventType, 120)
            XCTAssertEqual(scale, 3.0)
            XCTAssertEqual(velocity, 5.0)
            pinchCalled.fulfill()
        }
        collector.delegate = delegate
        collector.start()
        
        recognizer.scale = 3.0
        collector.handlePinch(gesture: recognizer)
        
        wait(for: [pinchCalled], timeout: 1)
        collector.stop()
        
        XCTAssertNotNil(TrapSwipeCollector.instance(withConfig: TrapConfig(), withQueue: OperationQueue()))
    }
}
