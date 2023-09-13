import NetworkExtension

extension NEHotspotHelper {
    static var fetchCurrentIsCalled: (() -> Void)?
    
    static func enableMock() {
        if self != NEHotspotHelper.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(NEHotspotHelper.supportedNetworkInterfaces)
            let newSelector = #selector(NEHotspotHelper.mocked_supportedNetworkInterfaces)
            let originalMethod = class_getClassMethod(NEHotspotHelper.self, originalSelector)
            let newMethod = class_getClassMethod(NEHotspotHelper.self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    static func disableMock() {
        if self != NEHotspotHelper.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(NEHotspotHelper.mocked_supportedNetworkInterfaces)
            let newSelector = #selector(NEHotspotHelper.supportedNetworkInterfaces)
            let originalMethod = class_getClassMethod(NEHotspotHelper.self, originalSelector)
            let newMethod = class_getClassMethod(NEHotspotHelper.self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
    }
    
    @objc class func mocked_supportedNetworkInterfaces() -> [NEHotspotNetwork] {
        NEHotspotHelper.fetchCurrentIsCalled?()
        
        class MockedNEHotspotNetwork: NEHotspotNetwork {
            override var ssid: String {
                get {
                    return "Network Just Connected"
                }
            }
            
            override var bssid: String {
                get {
                    "EF:CD:AB:89:67:45:23:01"
                }
            }
        }
        
        return [MockedNEHotspotNetwork()]
    }
}
