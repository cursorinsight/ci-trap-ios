import Trap
import Foundation

class MockCollector: TrapDatasource {
    static var startCalled: (() -> Void)? = nil
    static var stopCalled: (() -> Void)? = nil
    
    var delegate: Trap.TrapDatasourceDelegate?
    
    func checkConfiguration() -> Bool {
        return true
    }
    
    func checkPermission() -> Bool {
        return true
    }
    
    func requestPermission(_ success: @escaping () -> Void) {
        success()
    }
    
    func start(withConfig: Trap.TrapConfig.DataCollection) {
        MockCollector.startCalled?()
    }
    
    func stop() {
        MockCollector.stopCalled?()
    }
    
    static func instance(withQueue: OperationQueue) -> Trap.TrapDatasource {
        MockCollector()
    }
    
    
}
