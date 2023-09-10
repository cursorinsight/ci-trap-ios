import CoreMotion

extension CMMotionManager {
    static let q = DispatchQueue.global(qos: .default)
    static var tasks = [Int : Timer]()
    static var startAccelerometerCalled: (() -> Void)?
    static var stopAccelerometerCalled: (() -> Void)?

    
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
        
        CMMotionManager.tasks.values.forEach { $0.invalidate() }
        
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
        CMMotionManager.startAccelerometerCalled?()
        
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
        
        CMMotionManager.tasks[self.hashValue] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            handler(data, nil)
        }
        
        CMMotionManager.q.async {
            RunLoop.current.add(CMMotionManager.tasks[self.hashValue]!, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    @objc dynamic func mocked_stopAccelerometerUpdates() {
        CMMotionManager.stopAccelerometerCalled?()
        
        CMMotionManager.tasks[self.hashValue]?.invalidate()
        CMMotionManager.tasks.removeValue(forKey: self.hashValue)
    }
}
