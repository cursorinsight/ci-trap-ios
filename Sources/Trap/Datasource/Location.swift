import CoreLocation

let locationEventType = 109

public class TrapLocationCollector: NSObject, TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private let locationManager: CLLocationManager
    private var authSuccess: (() -> Void)?

    /// Create a collector which monitors for high accuracy
    /// location changes.
    public override init() {
        locationManager = CLLocationManager()

#if compiler(>=5.4.2)
        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        }
#else
        if #available(iOS 14.0, *) {} else {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
#endif
    }

    public func checkConfiguration() -> Bool {
        let alwaysAndWhenInUseOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSLocationAlwaysAndWhenInUseUsageDescription") ?? false
        let whenInUseOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSLocationWhenInUseUsageDescription") ?? false
        let alwaysOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSLocationWhenInUseUsageDescription") ?? false
        let genericOk = Bundle.main
            .infoDictionary?
            .keys
            .contains("NSLocationUsageDescription") ?? false

        return alwaysOk && whenInUseOk && alwaysAndWhenInUseOk && genericOk
    }

    public func checkPermission() -> Bool {
#if compiler(>=5.4.2)
        if #available(iOS 14, *) {
            switch locationManager.authorizationStatus {
            case .restricted, .denied, .notDetermined:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                break
            }
        }
#else
        if #available(iOS 14.0, *) {} else {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied, .notDetermined:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                break
            }
        }
#endif

        return false
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        authSuccess = success
        locationManager.requestWhenInUseAuthorization()
    }

    public func start(withConfig _: TrapConfig.DataCollection) {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }

    public func stop() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.delegate = nil
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapLocationCollector()
    }
}

/// CLLocationManagerDelegate implementation.
extension TrapLocationCollector: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied, .notDetermined:
            debugPrint("Location rights denied")
        case .authorizedAlways, .authorizedWhenInUse:
            authSuccess?()
            break
        @unknown default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Error with location manager \(error)")
        manager.stopUpdatingLocation()
    }

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coords = location.coordinate
            let timestamp = Int64(location.timestamp.timeIntervalSince1970 * 1000)
            delegate?.save(sequence: timestamp, data: DataType.array([
                DataType.int(locationEventType),
                DataType.int64(timestamp),
                DataType.double(Double(coords.latitude)),
                DataType.double(Double(coords.longitude)),
                DataType.double(Double(location.altitude)),
                DataType.double(Double(location.horizontalAccuracy))
            ]))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        debugPrint("Error with location manager \(String(describing: error))")
        manager.stopUpdatingLocation()
    }
}
