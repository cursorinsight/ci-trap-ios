import UIKit

let stylusMoveEventType = 111
let stylusDownEventType = 110
let stylusUpEventType = 112

/// Data collector for stylus touch  gestures
public final class TrapStylusCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers(_: UIWindow) -> [UIGestureRecognizer] {
        [StylusGestureRecognizer(self)]
    }

    public static func instance(withConfig config: Config, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapStylusCollector(withConfig: config)
    }

    deinit {
        stop()
    }
}

/// The stylus gesture recognizer.
private class StylusGestureRecognizer: UIGestureRecognizer {
    private let collector: TrapStylusCollector

    /// Create a Pencil/Stylus gesture recongizer isntance.
    public init(_ collector: TrapStylusCollector) {
        self.collector = collector

        super.init(target: nil, action: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(stylusDownEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.double(touch.force), // Force
                DataType.double(touch.altitudeAngle), // Altitude angle
                DataType.double(touch.azimuthAngle(in: touch.view)) // Azimuth angle
            ]))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let rawTouches = event?.coalescedTouches(for: touch) ?? [touch]
            rawTouches.forEach { touch in
                let loc = touch.location(in: touch.view)
                let timestamp = TrapTime.normalizeTime(touch.timestamp)
                self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(stylusMoveEventType), // Event Type
                    DataType.int64(timestamp), // Timestamp
                    DataType.double(loc.x), // X position
                    DataType.double(loc.y), // Y position
                    DataType.double(touch.force), // Force
                    DataType.double(touch.altitudeAngle), // Altitude angle
                    DataType.double(touch.azimuthAngle(in: touch.view)) // Azimuth angle
                ]))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(stylusUpEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.double(touch.force), // Force
                DataType.double(touch.altitudeAngle), // Altitude angle
                DataType.double(touch.azimuthAngle(in: touch.view)) // Azimuth angle
            ]))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .pencil {
                return
            }

            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(stylusUpEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.double(touch.force), // Force
                DataType.double(touch.altitudeAngle), // Altitude angle
                DataType.double(touch.azimuthAngle(in: touch.view)) // Azimuth angle
            ]))
        }
    }
}
