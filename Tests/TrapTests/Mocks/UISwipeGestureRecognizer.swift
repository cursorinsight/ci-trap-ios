import UIKit

extension UISwipeGestureRecognizer {
    static var _direction: UISwipeGestureRecognizer.Direction = .down
    @objc var mocked_direction: UISwipeGestureRecognizer.Direction {
        get {
            return UISwipeGestureRecognizer._direction
        }
        set {
            UISwipeGestureRecognizer._direction = newValue
        }
    }
    
    static func enableMock() {
        if self != UISwipeGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(getter: UISwipeGestureRecognizer.direction)
            let newSelector = #selector(getter: UISwipeGestureRecognizer.mocked_direction)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != UISwipeGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(getter: UISwipeGestureRecognizer.mocked_direction)
            let newSelector = #selector(getter: UISwipeGestureRecognizer.direction)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
}
