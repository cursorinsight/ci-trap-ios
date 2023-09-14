@testable import Trap
import Foundation

class MockTransport: TrapTransport {
    var startCalled: (() -> Void)?
    var stopCalled: (() -> Void)?
    var sendCalled: ((_: String) -> Void)?
    
    init() {}
    
    func start() {
        startCalled?()
    }
    
    func stop() {
        stopCalled?()
    }
    
    func send(data: String, completionHandler: @escaping (Error?) -> Void) {
        sendCalled?(data)
    }
    
    
}
