import CoreMotion

extension CMMotionManager {
    static let q = DispatchQueue.global(qos: .default)
    static var tasks = [Int : Timer]()
    static var startAccelerometerCalled: (() -> Void)?
    static var stopAccelerometerCalled: (() -> Void)?
    static var startGravityCalled: (() -> Void)?
    static var stopGravityCalled: (() -> Void)?
    static var startGyroscopeCalled: (() -> Void)?
    static var stopGyroscopeCalled: (() -> Void)?
    static var startMagnetometerCalled: (() -> Void)?
    static var stopMagnetometerCalled: (() -> Void)?

    
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
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.startDeviceMotionUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.mocked_startDeviceMotionUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.stopDeviceMotionUpdates)
            let newSelector = #selector(CMMotionManager.mocked_stopDeviceMotionUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.startGyroUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.mocked_startGyroUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.stopGyroUpdates)
            let newSelector = #selector(CMMotionManager.mocked_stopGyroUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.startMagnetometerUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.mocked_startMagnetometerUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.stopMagnetometerUpdates)
            let newSelector = #selector(CMMotionManager.mocked_stopMagnetometerUpdates)
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
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_startDeviceMotionUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.startDeviceMotionUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_stopDeviceMotionUpdates)
            let newSelector = #selector(CMMotionManager.stopDeviceMotionUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_startGyroUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.startGyroUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_stopGyroUpdates)
            let newSelector = #selector(CMMotionManager.stopGyroUpdates)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_startMagnetometerUpdates(to:withHandler:))
            let newSelector = #selector(CMMotionManager.startMagnetometerUpdates(to:withHandler:))
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CMMotionManager.mocked_stopMagnetometerUpdates)
            let newSelector = #selector(CMMotionManager.stopMagnetometerUpdates)
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
    
    @objc dynamic func mocked_startDeviceMotionUpdates(to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler) {
        CMMotionManager.startGravityCalled?()
        
        class MockedCMDeviceMotionData: CMDeviceMotion {
            var mockedTimestamp = -1.0
            override var timestamp: TimeInterval { get {
                mockedTimestamp = mockedTimestamp + 2.0;
                
                return mockedTimestamp
            } }
            
            var mockGravity = CMAcceleration(x: 0.0, y: 1.0, z: 0.0)
            
            override var gravity: CMAcceleration { get {
                mockGravity = CMAcceleration(
                    x: mockGravity.x + 2.0,
                    y: mockGravity.y - 2.0,
                    z: mockGravity.z - 2.0
                );
                
                return mockGravity
            } }
        }
        let data = MockedCMDeviceMotionData()
        
        CMMotionManager.tasks[self.hashValue] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            handler(data, nil)
        }
        
        CMMotionManager.q.async {
            RunLoop.current.add(CMMotionManager.tasks[self.hashValue]!, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    @objc dynamic func mocked_stopDeviceMotionUpdates() {
        CMMotionManager.stopGravityCalled?()
        
        CMMotionManager.tasks[self.hashValue]?.invalidate()
        CMMotionManager.tasks.removeValue(forKey: self.hashValue)
    }
    
    @objc dynamic func mocked_startGyroUpdates(to queue: OperationQueue, withHandler handler: @escaping CMGyroHandler) {
        CMMotionManager.startGyroscopeCalled?()
        
        class MockedCMGyroData: CMGyroData {
            var mockedTimestamp = -1.0
            override var timestamp: TimeInterval { get {
                mockedTimestamp = mockedTimestamp + 2.0;
                
                return mockedTimestamp
            } }
            
            var mockGyro = CMRotationRate(x: 0.0, y: 1.0, z: 0.0)
            
            override var rotationRate: CMRotationRate { get {
                mockGyro = CMRotationRate(
                    x: mockGyro.x + 2.0,
                    y: mockGyro.y - 2.0,
                    z: mockGyro.z - 2.0
                );
                
                return mockGyro
            } }
        }
        let data = MockedCMGyroData()
        
        CMMotionManager.tasks[self.hashValue] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            handler(data, nil)
        }
        
        CMMotionManager.q.async {
            RunLoop.current.add(CMMotionManager.tasks[self.hashValue]!, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    @objc dynamic func mocked_stopGyroUpdates() {
        CMMotionManager.stopGyroscopeCalled?()
        
        CMMotionManager.tasks[self.hashValue]?.invalidate()
        CMMotionManager.tasks.removeValue(forKey: self.hashValue)
    }
    
    @objc dynamic func mocked_startMagnetometerUpdates(to queue: OperationQueue, withHandler handler: @escaping CMMagnetometerHandler) {
        CMMotionManager.startMagnetometerCalled?()
        
        class MockedCMMagnetometerData: CMMagnetometerData {
            var mockedTimestamp = -1.0
            override var timestamp: TimeInterval { get {
                mockedTimestamp = mockedTimestamp + 2.0;
                
                return mockedTimestamp
            } }
            
            var mockMagneticField = CMMagneticField(x: 0.0, y: 1.0, z: 0.0)
            
            override var magneticField: CMMagneticField { get {
                mockMagneticField = CMMagneticField(
                    x: mockMagneticField.x + 2.0,
                    y: mockMagneticField.y - 2.0,
                    z: mockMagneticField.z - 2.0
                );
                
                return mockMagneticField
            } }
        }
        let data = MockedCMMagnetometerData()
        
        CMMotionManager.tasks[self.hashValue] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            handler(data, nil)
        }
        
        CMMotionManager.q.async {
            RunLoop.current.add(CMMotionManager.tasks[self.hashValue]!, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    @objc dynamic func mocked_stopMagnetometerUpdates() {
        CMMotionManager.stopMagnetometerCalled?()
        
        CMMotionManager.tasks[self.hashValue]?.invalidate()
        CMMotionManager.tasks.removeValue(forKey: self.hashValue)
    }
}
