import UIKit

let tapEventType = 122

/// Recognizes pinch gestures via the built-in UIPinchGestureRecognizer
public final class TrapTapCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers(_: UIWindow) -> [UIGestureRecognizer] {
        [UITapGestureRecognizer(target: self, action: #selector(handleTap))]
    }

    public static func instance(withConfig config: TrapConfig, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapTapCollector(withConfig: config)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: sender.view)

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(tapEventType),
            DataType.int64(timestamp),
            DataType.double(Double(point.x)),
            DataType.double(Double(point.y))
        ]))
    }
}
