import UIKit

let pinchEventType = 120

/// Recognizes pinch gestures via the built-in UIPinchGestureRecognizer
public final class TrapPinchCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers(_: UIWindow) -> [UIGestureRecognizer] {
        [UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))]
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(pinchEventType),
            DataType.int64(timestamp),
            DataType.double(gesture.scale),
            DataType.double(gesture.velocity)
        ]))
    }

    public static func instance(withConfig config: Config, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapPinchCollector(withConfig: config)
    }

    deinit {
        stop()
    }
}
