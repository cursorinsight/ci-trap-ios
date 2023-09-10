import UIKit

class UITouchMock: UITouch {
    var _type: TouchType = .direct
    override var type: TouchType {
        get {
            return _type
        }
        set {
            self._type = newValue
        }
    }
    
    var _timestamp: TimeInterval = TimeInterval.zero
    override var timestamp: TimeInterval {
        get {
            return _timestamp
        }
        set {
            self._timestamp = newValue
        }
    }
    
    var _force: CGFloat = CGFloat.zero
    override var force: CGFloat {
        get {
            return _force
        }
        set {
            self._force = newValue
        }
    }
    
    var _majorRadius: CGFloat = CGFloat.zero
    override var majorRadius: CGFloat {
        get {
            return _majorRadius
        }
        set {
            self._majorRadius = newValue
        }
    }
    
    public var _location: CGPoint = CGPoint.zero
    
    
    override func location(in view: UIView?) -> CGPoint {
        return _location
    }
    
    
}
