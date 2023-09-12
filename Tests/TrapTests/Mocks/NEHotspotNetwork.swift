import NetworkExtension

@available(iOS 14.0, *)
extension NEHotspotNetwork {
    static var fetchCurrentIsCalled: (() -> Void)?
    
    static func enableMock() {
        if self != NEHotspotNetwork.self {
            return
        }
#if compiler(>=5.4.2)
        let _: () = {
            let originalSelector = #selector(NEHotspotNetwork.fetchCurrent(completionHandler:))
            let newSelector = #selector(NEHotspotNetwork.mocked_fetchCurrent(completionHandler:))
            let originalMethod = class_getClassMethod(NEHotspotNetwork.self, originalSelector)
            let newMethod = class_getClassMethod(NEHotspotNetwork.self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
#endif
    }
    
    static func disableMock() {
        if self != NEHotspotNetwork.self {
            return
        }
        
#if compiler(>=5.4.2)
        let _: () = {
            let originalSelector = #selector(NEHotspotNetwork.mocked_fetchCurrent(completionHandler:))
            let newSelector = #selector(NEHotspotNetwork.fetchCurrent(completionHandler:))
            let originalMethod = class_getClassMethod(NEHotspotNetwork.self, originalSelector)
            let newMethod = class_getClassMethod(NEHotspotNetwork.self, newSelector)
            method_exchangeImplementations(originalMethod!, newMethod!)
        }()
#endif
    }
    
    @objc class func mocked_fetchCurrent(completionHandler: @escaping (NEHotspotNetwork?) -> Void) {
        NEHotspotNetwork.fetchCurrentIsCalled?()
        
        class MockedNEHotspotNetwork: NEHotspotNetwork {
            override var ssid: String {
                get {
                    return "Test Network"
                }
            }
            
            override var bssid: String {
                get {
                    "01:23:45:67:89:AB:CD:EF"
                }
            }
        }
        
        let mockNetwork = MockedNEHotspotNetwork()
        completionHandler(mockNetwork)
    }
}

