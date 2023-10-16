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
    
    func start() {
        MockCollector.startCalled?()
    }
    
    func stop() {
        MockCollector.stopCalled?()
    }
    
    static func instance(withConfig: Trap.TrapConfig.DataCollection, withQueue: OperationQueue) -> Trap.TrapDatasource {
        MockCollector()
    }
    
    
}
