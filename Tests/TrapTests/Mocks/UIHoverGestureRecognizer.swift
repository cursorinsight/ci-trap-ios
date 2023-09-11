import UIKit

class UIHoverGestureRecognizerMock: UIHoverGestureRecognizer {
    override var view: UIView {
        get {
            return UIView()
        }
    }
    
    var _location: CGPoint = CGPoint.zero
    override func location(in _: UIView?) -> CGPoint {
        return _location
    }
}
