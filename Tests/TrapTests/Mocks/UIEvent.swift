import UIKit

class UIEventMock: UIEvent {
    public var _touches: [UITouch]?
    public var _buttonMask: Int = 0
    
    override func coalescedTouches(for touch: UITouch) -> [UITouch]? {
        return _touches
    }
}

@available(iOS 13.4, *)
extension UIEventMock {
    public override var buttonMask: UIEvent.ButtonMask {
        get {
            switch _buttonMask {
            case 0:
                return .primary
            case 1:
                return .secondary
            default:
                return .primary
            }
        }
        set {
            switch newValue {
            case .primary:
                self._buttonMask = 0
                break
            case .secondary:
                self._buttonMask = 1
                break
            default:
                break
            }
        }
    }
}
