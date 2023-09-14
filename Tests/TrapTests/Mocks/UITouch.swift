import UIKit

class UITouchMock: UITouch {
    var _type: TouchType = .direct
    override var type: TouchType {
        get {
            return _type
        }
    }
    
    var _timestamp: TimeInterval = TimeInterval.zero
    override var timestamp: TimeInterval {
        get {
            return _timestamp
        }
    }
    
    var _force: CGFloat = CGFloat.zero
    override var force: CGFloat {
        get {
            return _force
        }
    }
    
    var _majorRadius: CGFloat = CGFloat.zero
    override var majorRadius: CGFloat {
        get {
            return _majorRadius
        }
    }
    
    public var _location: CGPoint = CGPoint.zero
    
    
    override func location(in view: UIView?) -> CGPoint {
        return _location
    }
    
    var _altitudeAngle: CGFloat = CGFloat.zero
    override var altitudeAngle: CGFloat {
        get {
            return _altitudeAngle
        }
    }
    
    var _azimuthAngle: CGFloat = CGFloat.zero
    override func azimuthAngle(in _: UIView?) -> CGFloat {
        _azimuthAngle
    }
}
