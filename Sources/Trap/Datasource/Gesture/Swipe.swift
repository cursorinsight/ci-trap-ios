import UIKit

let swipeEventType = 121

/// Data collector for processed swipe  gestures
public final class TrapSwipeCollector: TrapGestureCollector, TrapDatasource {
    override public func createRecongizers() -> [UIGestureRecognizer] {
        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        right.direction = .right

        let down = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        down.direction = .down

        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        left.direction = .left

        let up = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        up.direction = .up

        return [right, down, left, up]
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapSwipeCollector()
    }

    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        let timestamp = TrapTime.getCurrentTime()
        var direction = ""
        switch sender.direction {
        case .right:
            direction = "right"
        case .down:
            direction = "down"
        case .left:
            direction = "left"
        case .up:
            direction = "up"
        default:
            assertionFailure("Unknown direction \(sender.direction)")
        }

        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(swipeEventType),
            DataType.int64(timestamp),
            DataType.string(direction)
        ]))
    }

    deinit {
        stop()
    }
}
