@testable import Trap
import Foundation

class MockTransport: TrapTransport {
    var startCalled: (() -> Void)?
    var stopCalled: (() -> Void)?
    var sendCalled: ((_: String) -> Void)?
    public var error = false
    
    init() {}
    
    func start() {
        startCalled?()
    }
    
    func stop() {
        stopCalled?()
    }
    
    func send(data: String, avoidSendingTooMuchData: Bool = false, completionHandler: @escaping (Error?) -> Void) {
        sendCalled?(data)
        if error {
            completionHandler(MockTransportError.general)
        } else {
            completionHandler(nil)
        }
    }
    
    
}

enum MockTransportError: Error {
    case general
}
