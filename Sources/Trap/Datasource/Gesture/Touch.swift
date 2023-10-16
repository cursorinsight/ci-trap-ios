import UIKit

let touchStartEventType = 100
let touchMoveEventType = 101
let touchStopEventType = 102

/// Collects raw touch events from all windows and scenes.
///
/// Upon calling 'start' an instance of our data logging gesture recognizer is registered
/// for each window in the applicatoin. Furthermore we register an observer for when
/// new window becomes visible or hidden. When a window is hidden, we de-register
/// the data collector gesture handler and when a window becomes visible, we
/// re-register the gesture handler.
///
/// During operation we try to be as stringent with CPU as possible, and use a little
/// more memory if it saves us repeated memory allocations so as to not compromise
/// performance of the embedding application.
public final class TrapTouchCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers() -> [UIGestureRecognizer] {
        let recognizer = TouchRecognizer(self)
        recognizer.delegate = recognizer
        return [recognizer]
    }

    public static func instance(withConfig config: TrapConfig, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapTouchCollector(withConfig: config)
    }

    // Stop the collector on deinit.
    deinit {
        stop()
    }
}

/// The custom recognizer to add to the UIWIndow recognizer list
public class TouchRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private let collector: TrapTouchCollector
    private var fingers = [UITouch?](repeating: nil, count: 5)

    public init(_ collector: TrapTouchCollector) {
        self.collector = collector
        super.init(target: nil, action: nil)
    }

    // MARK: Touches began

    private func _touchesBegan(_ touch: UITouch, _ fingerIndex: Int) {
#if compiler(>=5.4.2)
        if #available(iOS 13.4, *) {
            if touch.type != .direct {
                return
            }
        }
#endif

        let loc = touch.location(in: nil)
        let timestamp = TrapTime.normalizeTime(touch.timestamp)
        collector.delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(touchStartEventType), // Event Type
            DataType.int64(timestamp), // Timestamp
            DataType.int(fingerIndex), // Finger identifier
            DataType.double(Double(loc.x)), // X position
            DataType.double(Double(loc.y)), // Y position
            DataType.double(Double(touch.force)), // Force of touch
            DataType.double(Double(touch.majorRadius)) // Major radius

        ]))
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let fingerIndex: Int = {
                if let idx = fingers.firstIndex(of: nil) {
                    fingers[idx] = touch
                    return Int(idx)
                } else {
                    fingers.append(touch)
                    return fingers.count
                }
            }()

            let rawTouch = (collector.config?.collectCoalescedTouchEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouch.forEach { _touchesBegan($0, fingerIndex) }
        }
    }

    // MARK: Touches in progress

    private func _touchesMoved(_ touch: UITouch, _ fingerIndex: Int) {
#if compiler(>=5.4.2)
        if #available(iOS 13.4, *) {
            if touch.type != .direct {
                return
            }
        }
#endif

        let loc = touch.location(in: nil)
        let timestamp = TrapTime.normalizeTime(touch.timestamp)
        collector.delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(touchMoveEventType), // Event Type
            DataType.int64(timestamp), // Timestamp
            DataType.int(fingerIndex), // Finger identifier
            DataType.double(Double(loc.x)), // X position
            DataType.double(Double(loc.y)), // Y position
            DataType.double(Double(touch.force)), // Force of touch
            DataType.double(Double(touch.majorRadius)) // Major radius
        ]))
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let fingerIndex = fingers.firstIndex(of: touch) ?? -1
            let rawTouches = (collector.config?.collectCoalescedTouchEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { _touchesMoved($0, fingerIndex) }
            if fingerIndex < 0 {
                print("touchesMoved: Unknown touch")
            }
        }
    }

    // MARK: Touches ended or cancelled

    private func _touchesEnded(_ touch: UITouch, _ fingerIndex: Int) {
#if compiler(>=5.4.2)
        if #available(iOS 13.4, *) {
            if touch.type != .direct {
                return
            }
        }
#endif

        let loc = touch.location(in: nil)
        let timestamp = TrapTime.normalizeTime(touch.timestamp)
        collector.delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(touchStopEventType), // Event Type
            DataType.int64(timestamp), // Timestamp
            DataType.int(fingerIndex), // Finger identifier
            DataType.double(Double(loc.x)), // X position
            DataType.double(Double(loc.y)), // Y position
            DataType.double(Double(touch.force)), // Force of touch
            DataType.double(Double(touch.majorRadius)) // Major radius
        ]))
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let fingerIndex = fingers.firstIndex(of: touch) ?? -1
            let rawTouches = (collector.config?.collectCoalescedTouchEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { _touchesEnded($0, fingerIndex) }
            if fingerIndex > -1 {
                fingers[fingerIndex] = nil
            } else {
                print("touchesEnded: Unknown touch")
            }
        }
    }

    private func _touchesCancelled(_ touch: UITouch, _ fingerIndex: Int) {
#if compiler(>=5.4.2)
        if #available(iOS 13.4, *) {
            if touch.type != .direct {
                return
            }
        }
#endif

        let loc = touch.location(in: nil)
        let timestamp = TrapTime.normalizeTime(touch.timestamp)
        collector.delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(touchStopEventType), // Event Type
            DataType.int64(timestamp), // Timestamp
            DataType.int(fingerIndex), // Finger identifier
            DataType.double(Double(loc.x)), // X position
            DataType.double(Double(loc.y)), // Y position
            DataType.double(Double(touch.force)), // Force of touch
            DataType.double(Double(touch.majorRadius)) // Major radius
        ]))
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let fingerIndex = fingers.firstIndex(of: touch) ?? -1
            let rawTouches = (collector.config?.collectCoalescedTouchEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { _touchesCancelled($0, fingerIndex) }
            if fingerIndex > -1 {
                fingers[fingerIndex] = nil
            } else {
                print("touchesCancelled: Unknown touch")
            }
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /// This is needed to avoid stealing events from UIKit controls
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view is UIControl else { return true }
        touchesBegan(Set([touch]), with: nil)
        return false
    }
}
