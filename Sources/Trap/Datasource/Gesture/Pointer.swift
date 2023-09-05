import UIKit

let mouseMoveEventType = 0
let mouseDownEventType = 5
let mouseUpEventType = 6

/// Data collector for pointer  gestures
@available(iOS 13.4, *)
public final class TrapPointerCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers(_: UIWindow) -> [UIGestureRecognizer] {
        [
            UIHoverGestureRecognizer(target: self, action: #selector(handleHover)),
            PointerClickRecognizer(self)
        ]
    }

    /// Checks the app configuration if it's ready to collect pointer events.
    override public func checkConfiguration() -> Bool {
        Bundle.main
            .infoDictionary?
            .keys
            .contains("UIApplicationSupportsIndirectInputEvents") ?? false
    }

    @objc func handleHover(_ sender: UIHoverGestureRecognizer) {
        guard let view = sender.view else {
            return
        }

        let loc = sender.location(in: view)
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(mouseMoveEventType), // Event Type
            DataType.int64(timestamp), // Timestamp
            DataType.double(loc.x), // X position
            DataType.double(loc.y), // Y position
            DataType.int(0)
        ]))
    }

    public static func instance(withConfig config: Config, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapPointerCollector(withConfig: config)
    }

    deinit {
        stop()
    }
}

/// The pointer click recognizer.
@available(iOS 13.4, *)
private class PointerClickRecognizer: UIGestureRecognizer {
    private var collector: TrapPointerCollector

    /// Create a Pointer Click Gesture recongizer isntance.
    public init(_ collector: TrapPointerCollector) {
        self.collector = collector

        super.init(target: nil, action: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .indirectPointer {
                return
            }

            let button = event?.buttonMask == .secondary ? 1 : 0
            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(mouseDownEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.int(button)
            ]))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .indirectPointer {
                return
            }

            let button = event?.buttonMask == .secondary ? 1 : 0
            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(mouseMoveEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.int(button)
            ]))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .indirectPointer {
                return
            }

            let button = event?.buttonMask == .secondary ? 1 : 0
            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(mouseUpEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.int(button)
            ]))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if touch.type != .indirectPointer {
                return
            }

            let button = event?.buttonMask == .secondary ? 1 : 0
            let loc = touch.location(in: touch.view)
            let timestamp = TrapTime.normalizeTime(touch.timestamp)
            self.collector.delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(mouseUpEventType), // Event Type
                DataType.int64(timestamp), // Timestamp
                DataType.double(loc.x), // X position
                DataType.double(loc.y), // Y position
                DataType.int(button)
            ]))
        }
    }
}
