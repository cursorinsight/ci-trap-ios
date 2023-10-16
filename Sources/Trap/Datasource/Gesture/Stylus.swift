import UIKit

let stylusMoveEventType = 111
let stylusDownEventType = 110
let stylusUpEventType = 112

/// Data collector for stylus touch  gestures
public final class TrapStylusCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers() -> [UIGestureRecognizer] {
        let recognizer = StylusGestureRecognizer(self)
        recognizer.delegate = recognizer
        return [recognizer]
    }

    public static func instance(withConfig config: TrapConfig, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapStylusCollector(withConfig: config)
    }

    deinit {
        stop()
    }
}

/// The stylus gesture recognizer.
private class StylusGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private let collector: TrapStylusCollector

    /// Create a Pencil/Stylus gesture recongizer isntance.
    public init(_ collector: TrapStylusCollector) {
        self.collector = collector
        super.init(target: nil, action: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let rawTouches = (collector.config?.collectCoalescedStylusEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { touch in
                let loc = touch.location(in: touch.view)
                let timestamp = TrapTime.normalizeTime(touch.timestamp)
                self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(stylusDownEventType), // Event Type
                    DataType.int64(timestamp), // Timestamp
                    DataType.double(Double(loc.x)), // X position
                    DataType.double(Double(loc.y)), // Y position
                    DataType.double(Double(touch.force)), // Force
                    DataType.double(Double(touch.altitudeAngle)), // Altitude angle
                    DataType.double(Double(touch.azimuthAngle(in: touch.view))) // Azimuth angle
                ]))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let rawTouches = (collector.config?.collectCoalescedStylusEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { touch in
                let loc = touch.location(in: touch.view)
                let timestamp = TrapTime.normalizeTime(touch.timestamp)
                self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(stylusMoveEventType), // Event Type
                    DataType.int64(timestamp), // Timestamp
                    DataType.double(Double(loc.x)), // X position
                    DataType.double(Double(loc.y)), // Y position
                    DataType.double(Double(touch.force)), // Force
                    DataType.double(Double(touch.altitudeAngle)), // Altitude angle
                    DataType.double(Double(touch.azimuthAngle(in: touch.view))) // Azimuth angle
                ]))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let rawTouches = (collector.config?.collectCoalescedStylusEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { touch in
                let loc = touch.location(in: touch.view)
                let timestamp = TrapTime.normalizeTime(touch.timestamp)
                self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(stylusUpEventType), // Event Type
                    DataType.int64(timestamp), // Timestamp
                    DataType.double(Double(loc.x)), // X position
                    DataType.double(Double(loc.y)), // Y position
                    DataType.double(Double(touch.force)), // Force
                    DataType.double(Double(touch.altitudeAngle)), // Altitude angle
                    DataType.double(Double(touch.azimuthAngle(in: touch.view))) // Azimuth angle
                ]))
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let rawTouches = (collector.config?.collectCoalescedStylusEvents ?? false)
                ? event?.coalescedTouches(for: touch) ?? [touch]
                : [touch]
            rawTouches.forEach { touch in
                let loc = touch.location(in: touch.view)
                let timestamp = TrapTime.normalizeTime(touch.timestamp)
                self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(stylusUpEventType), // Event Type
                    DataType.int64(timestamp), // Timestamp
                    DataType.double(Double(loc.x)), // X position
                    DataType.double(Double(loc.y)), // Y position
                    DataType.double(Double(touch.force)), // Force
                    DataType.double(Double(touch.altitudeAngle)), // Altitude angle
                    DataType.double(Double(touch.azimuthAngle(in: touch.view))) // Azimuth angle
                ]))
            }
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /// This is needed to avoid stealing events from UIKit controls
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view is UIControl else {return true}
        touchesBegan(Set([touch]), with: nil)
        return false
    }}
