import UIKit

extension UIPinchGestureRecognizer {
    @objc var mocked_velocity: CGFloat {
        get {
            return 5.0
        }
    }
    
    static func enableMock() {
        if self != UIPinchGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(getter: UIPinchGestureRecognizer.velocity)
            let newSelector = #selector(getter: UIPinchGestureRecognizer.mocked_velocity)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != UIPinchGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(getter: UIPinchGestureRecognizer.mocked_velocity)
            let newSelector = #selector(getter: UIPinchGestureRecognizer.velocity)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
}
