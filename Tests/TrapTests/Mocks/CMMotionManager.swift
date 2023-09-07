import Combine
import CoreMotion

extension CMMotionManager {
    static var tasks = [Int : Cancellable]()

    
    static func enableMock() {
        if self != CMMotionManager.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.startAccelerometerUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.mocked_startAccelerometerUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.stopAccelerometerUpdates)
            let newSelector = #selector(CMMotionManager.mocked_stopAccelerometerUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != CMMotionManager.self {
            return
        }
        
        CMMotionManager.tasks.values.forEach { $0.cancel() }
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_startAccelerometerUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.startAccelerometerUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_stopAccelerometerUpdates)
            let newSelector = #selector(CMMotionManager.stopAccelerometerUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    @objc dynamic func mocked_startAccelerometerUpdates(to queue: OperationQueue, withHandler handler: @escaping CMAccelerometerHandler) {
        class MockedCMAccelerometerData: CMAccelerometerData {
            var mockedTimestamp = -1.0
            override var timestamp: TimeInterval { get {
                mockedTimestamp = mockedTimestamp + 2.0;
                
                return mockedTimestamp
            } }
            
            var mockAcceleration = CMAcceleration(x: 0.0, y: 1.0, z: 0.0)
            
            override var acceleration: CMAcceleration { get {
                mockAcceleration = CMAcceleration(
                    x: mockAcceleration.x + 2.0,
                    y: mockAcceleration.y - 2.0,
                    z: mockAcceleration.z - 2.0
                );
                
                return mockAcceleration
            } }
        }
        let data = MockedCMAccelerometerData()
        
        CMMotionManager.tasks[self.hashValue] = queue.schedule(
            after: .init(Date(timeIntervalSinceNow: 1)),
            interval: .milliseconds(20)
        ) {
            print("QUEUE")
            handler(data, nil)
        }
    }
    
    @objc dynamic func mocked_stopAccelerometerUpdates() {
        CMMotionManager.tasks[self.hashValue]?.cancel()
    }
}
