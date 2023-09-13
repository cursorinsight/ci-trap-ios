import UIKit

extension UITapGestureRecognizer {
    static func enableMock() {
        if self != UITapGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(UITapGestureRecognizer.location(in:))
            let newSelector = #selector(UITapGestureRecognizer.mocked_location(in:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != UITapGestureRecognizer.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(UITapGestureRecognizer.mocked_location(in:))
            let newSelector = #selector(UITapGestureRecognizer.location(in:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    @objc func mocked_location(in: UIView?) -> CGPoint {
        return CGPoint(x: 35.0, y: 55.0)
    }
}
