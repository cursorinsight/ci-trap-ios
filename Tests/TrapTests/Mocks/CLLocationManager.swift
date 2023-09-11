import CoreLocation

extension CLLocationManager {
    static var startSignificantLocationCalled: (() -> Void)?
    static var stopSignificantLocationCalled: (() -> Void)?
    static var startLocationCalled: (() -> Void)?
    static var stopLocationCalled: (() -> Void)?
    
    static var tasks = [Int : Timer]()
    static let q = DispatchQueue.global(qos: .default)
    
    static var _accuracy: CLLocationAccuracy = .greatestFiniteMagnitude
    var desiredAccuracy: CLLocationAccuracy {
        get {
            return CLLocationManager._accuracy
        }
        set {
            CLLocationManager._accuracy = newValue
        }
    }
    
    static func enableMock() {
        if self != CLLocationManager.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.startMonitoringSignificantLocationChanges)
            let newSelector = #selector(CLLocationManager.mocked_startMonitoringSignificantLocationChanges)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.stopMonitoringSignificantLocationChanges)
            let newSelector = #selector(CLLocationManager.mocked_stopMonitoringSignificantLocationChanges)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.startUpdatingLocation)
            let newSelector = #selector(CLLocationManager.mocked_startUpdatingLocation)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.stopUpdatingLocation)
            let newSelector = #selector(CLLocationManager.mocked_stopUpdatingLocation)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != CLLocationManager.self {
            return
        }
        
        CLLocationManager.tasks.values.forEach { $0.invalidate() }
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.mocked_startMonitoringSignificantLocationChanges)
            let newSelector = #selector(CLLocationManager.startMonitoringSignificantLocationChanges)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.mocked_stopMonitoringSignificantLocationChanges)
            let newSelector = #selector(CLLocationManager.stopMonitoringSignificantLocationChanges)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.mocked_startUpdatingLocation)
            let newSelector = #selector(CLLocationManager.startUpdatingLocation)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
        
        let _: () = {
            let originalSelector = #selector(CLLocationManager.mocked_stopUpdatingLocation)
            let newSelector = #selector(CLLocationManager.stopUpdatingLocation)
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let newMethod = class_getInstanceMethod(self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    
    
    @objc func mocked_startMonitoringSignificantLocationChanges() {
        CLLocationManager.startSignificantLocationCalled?()
        
        self.delegate?.locationManager?(self, didChangeAuthorization: .authorizedAlways)

        var mockLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 11.0, longitude: 12.0),
            altitude: 13.0,
            horizontalAccuracy: 14.0,
            verticalAccuracy: 15.0,
            timestamp: Date(timeIntervalSince1970: 1.0)
        )
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
            mockLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(
                    latitude: mockLocation.coordinate.latitude + 2.0,
                    longitude: mockLocation.coordinate.longitude + 2.0
                ),
                altitude: mockLocation.altitude + 2.0,
                horizontalAccuracy: mockLocation.horizontalAccuracy + 2.0,
                verticalAccuracy: mockLocation.verticalAccuracy + 2.0,
                timestamp: mockLocation.timestamp.addingTimeInterval(2.0)
            )
        }
        CLLocationManager.tasks[self.hashValue] = timer
        
        CLLocationManager.q.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    @objc func mocked_stopMonitoringSignificantLocationChanges() {
        CLLocationManager.stopSignificantLocationCalled?()
        
        CLLocationManager.tasks[self.hashValue]?.invalidate()
        CLLocationManager.tasks.removeValue(forKey: self.hashValue)
    }
                                             
    @objc func mocked_startUpdatingLocation() {
        CLLocationManager.startLocationCalled?()
        
        self.delegate?.locationManager?(self, didChangeAuthorization: .authorizedAlways)
        
        var mockLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 11.0, longitude: 12.0),
            altitude: 13.0,
            horizontalAccuracy: 14.0,
            verticalAccuracy: 15.0,
            timestamp: Date(timeIntervalSince1970: 1.0)
        )
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
            mockLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(
                    latitude: mockLocation.coordinate.latitude + 2.0,
                    longitude: mockLocation.coordinate.longitude + 2.0
                ),
                altitude: mockLocation.altitude + 2.0,
                horizontalAccuracy: mockLocation.horizontalAccuracy + 2.0,
                verticalAccuracy: mockLocation.verticalAccuracy + 2.0,
                timestamp: mockLocation.timestamp.addingTimeInterval(2.0)
            )
        }
        CLLocationManager.tasks[self.hashValue] = timer
        
        CLLocationManager.q.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }

    @objc func mocked_stopUpdatingLocation() {
        CLLocationManager.stopLocationCalled?()
        
        CLLocationManager.tasks[self.hashValue]?.invalidate()
        CLLocationManager.tasks.removeValue(forKey: self.hashValue)
    }
}
