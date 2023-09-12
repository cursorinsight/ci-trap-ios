//
//  File.swift
//  
//
//  Created by Márk Tolmács on 2023. 09. 12..
//

import CoreBluetooth

//extension CBPeripheral {
//    var delegate: CBPeripheralDelegate {
//        get {
//            class Mock: NSObject, CBPeripheralDelegate {}
//            return Mock()
//        }
//    }
//    
//    @objc open var name: String {
//        get {
//            return "Test Device"
//        }
//    }
//    
//    open override var identifier: UUID {
//        get {
//            return UUID.init(uuidString: "1698dfb1-b8bb-432f-a975-306dd31a29f4")!
//        }
//    }
//    
//    @objc open var state: CBPeripheralState {
//        get {
//            return .connected
//        }
//    }
//
//}

class MockCBPeripheral: CBPeripheral {
    class Mock: NSObject, CBPeripheralDelegate {}
    
    static var __subdelegate: CBPeripheralDelegate = Mock()
    
    static func create() -> Self {
        let instance = Self.perform(NSSelectorFromString("new")).takeRetainedValue() as! Self
        
        instance.delegate = MockCBPeripheral.__subdelegate
        return instance
    }
}
