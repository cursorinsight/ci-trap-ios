import CoreLocation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

let wifiNetworkEventType = 107

/// A collector for connected WiFi APs this device uses. If the app
/// has the special hotspot helper entitlement, it can list
/// available WiFi networks too.
public class TrapWiFiCollector: TrapDatasource {
    public var delegate: TrapDatasourceDelegate?
    private var networkMonitor: NWPathMonitor
    private let locationManager: CLLocationManager
    private var locationDelegate: TrapWifiDelegate

    /// Create a new wifi network collector instance.
    public init(withConfig _: TrapConfig? = nil) {
        networkMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
        locationManager = CLLocationManager()
        locationDelegate = TrapWifiDelegate()
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
        // https://developer.apple.com/documentation/systemconfiguration/1614126-cncopycurrentnetworkinfo
#if compiler(>=5.4.2)
        if #available(iOS 14.0, *) {
            if NEDNSSettingsManager.shared().isEnabled {
                return true
            }
        }
#endif

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
        if #available(iOS 14, *) {} else {
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
        locationDelegate.authSuccess = success
        locationManager.requestWhenInUseAuthorization()
    }

    public func start() {
        networkMonitor.pathUpdateHandler = { [weak self] _ in self?.getSSID() }
        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
        getSSID()
    }

    public func stop() {
        networkMonitor.cancel()
    }

    public static func instance(withConfig config: TrapConfig, withQueue queue: OperationQueue) -> TrapDatasource {
        TrapWiFiCollector(withConfig: config)
    }

    private func getSSID() {
        var ssid: String?
        var bssid: String?

#if compiler(>=5.4.2)
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent(completionHandler: { [weak self] currentNetwork in
                
                guard let network = currentNetwork else { return }
                ssid = network.ssid
                bssid = network.bssid

                let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
                self?.delegate?.save(sequence: timestamp, data: DataType.array([
                    DataType.int(wifiNetworkEventType),
                    DataType.int64(timestamp),
                    DataType.array([
                        DataType.string(ssid ?? "<unknown>"),
                        DataType.string(bssid ?? "<unknown>"),
                        DataType.int(2)
                    ])
                ]))
            })

            if case let networks? = NEHotspotHelper.supportedNetworkInterfaces() as? [NEHotspotNetwork] {
                for network in networks {
                    if ssid != network.ssid, bssid != network.bssid {
                        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
                        self.delegate?.save(sequence: timestamp, data: DataType.array([
                            DataType.int(wifiNetworkEventType),
                            DataType.int64(timestamp),
                            DataType.array([
                                DataType.string(network.ssid),
                                DataType.string(network.bssid),
                                DataType.int(1)
                            ])
                        ]))
                    }
                }
            }
        }
#else
        if #available(iOS 14.0, *) {} else {
            if let interfaces = CNCopySupportedInterfaces() as NSArray? {
                for interface in interfaces {
                    if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                        ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                        bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
                        delegate?.save(sequence: timestamp, data: DataType.array([
                            DataType.int(wifiNetworkEventType),
                            DataType.int64(timestamp),
                            DataType.array([
                                DataType.string(ssid ?? "<unknown>"),
                                DataType.string(bssid ?? "<unknown>"),
                                DataType.int(1)
                            ])
                        ]))
                    }
                }
            }
        }
#endif
    }
}

internal class TrapWifiDelegate: NSObject, CLLocationManagerDelegate {
    internal var authSuccess: (() -> Void)?

    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied, .notDetermined:
            debugPrint("Location rights denied")
        case .authorizedAlways, .authorizedWhenInUse:
            authSuccess?()
        @unknown default:
            break
        }
    }
}
