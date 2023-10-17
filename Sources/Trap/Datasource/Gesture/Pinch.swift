import UIKit

let pinchEventType = 120

/// Recognizes pinch gestures via the built-in UIPinchGestureRecognizer
public final class TrapPinchCollector: TrapGestureCollector, TrapDatasource {

    override public func createRecongizers() -> [UIGestureRecognizer] {
        [UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))]
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let timestamp = TrapTime.getCurrentTime()
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(pinchEventType),
            DataType.int64(timestamp),
            DataType.double(Double(gesture.scale)),
            DataType.double(Double(gesture.velocity))
        ]))
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapPinchCollector()
    }

    deinit {
        stop()
    }
}
