import UIKit

class UIEventMock: UIEvent {
    public var _touches: [UITouch]?
    
    override func coalescedTouches(for touch: UITouch) -> [UITouch]? {
        return _touches
    }
}
