import UIKit

extension UIWindow {
    static var mock_recognizers: [Int: UIGestureRecognizer] = [:]
    
    static func enableMock() {
        if self != UIWindow.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(UIWindow.addGestureRecognizer(_:))
            let newSelector = #selector(UIWindow.mocked_addGestureRecognizer(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(UIWindow.removeGestureRecognizer(_:))
            let newSelector = #selector(UIWindow.mocked_removeGestureRecognizer(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        let _: () = {
            let originalSelector = #selector(UIWindow.mocked_addGestureRecognizer(_:))
            let newSelector = #selector(UIWindow.addGestureRecognizer(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(UIWindow.mocked_removeGestureRecognizer(_:))
            let newSelector = #selector(UIWindow.removeGestureRecognizer(_:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    @objc dynamic func mocked_addGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        if !filterSystemGestures(recognizer) {
            UIWindow.mock_recognizers[recognizer.hash] = recognizer
        }
    }
    
    @objc dynamic func mocked_removeGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        if !filterSystemGestures(recognizer) {
            UIWindow.mock_recognizers.removeValue(forKey: recognizer.hash)
        }
    }
    
    private func filterSystemGestures(_ recognizer: UIGestureRecognizer) -> Bool {
        switch true {
        case recognizer.description.starts(with: "<_UIFocusMovement"):
            return true
        case recognizer.description.starts(with: "<_UISystemGesture"):
            return true
        default:
            return false
        }
    }
}
