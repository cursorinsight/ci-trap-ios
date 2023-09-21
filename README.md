# Trap Library for iOS and iPadOS
This library can collect various device and user data, forwarding it to a specified endpoint. The following data collectors are bundled with this version:
* Accelerometer
* Bluetooth LE devices connected / peered 
* Approximate and precise location
* Gravity
* Gyroscope
* Indirect pointer (mouse)
* Magnetometer
* Pencil and stylus
* Pinch gesture
* Raw touch
* Swipe gesture
* Tap gesture
* WiFi connection and available networks

## How to use it
You can check out the Example app for a working example 
```swift
import Trap
import SwiftUI

@main
struct ExampleApp: App {
    let trapManager: TrapManager

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    public init() {
        /// Create a new configuration instance.
        var config = TrapConfig()
        
        /// Change what you need to change
        config.reporter.interval = .seconds(3)
        
        /// Set either a websocket endpoint...
        config.reporter.url "wss://example.com/api/ws"
        
        /// ...or a HTTP POST endpont.
        config.reporter.url = "https://example.com/api/post"
        
        trapManager = try! TrapManager(withConfig: config)

        // Run all default collectors...
        trapManager.runAll()
        
        // ...or use it one collector at a time
        let collector = TrapPreciseLocationCollector(withConfig: config)
        
        /// Check if the build-time conditions are ready for the collector
        if collector.checkConfiguration() {
            /// Check if the runtime permissions are given.
            if !collector.checkPermission() {
                /// Request the permission if you need to
                collector.requestPermission { [self] in trapManager.run(collector: collector) }
            } else {
                /// ...or run the collector immediately.
                trapManager.run(collector: collector)
            }
        }
    }
}
```

## Permissions
Many of the available data collectors require app bundle records (Info.plist) and/or entitlemens. Some of them needs Apple's special approval. Below are the details for each collector:

### Accelerometer, Gravity, Gyroscope, Magnetometer
The only requirement is to have the bundle record 'NSMotionUsageDescription' defined and filled in.

### Bluetooth LE
The only requirement is to have the bundle record 'NSBluetoothAlwaysUsageDescription' defined and filled in. Requires runtime permission from the user.

### Approximate and precise location
The following bundle records need to be set:
* NSLocationAlwaysAndWhenInUseUsageDescription
* NSLocationWhenInUseUsageDescription
* NSLocationWhenInUseUsageDescription
* NSLocationUsageDescription

Requires runtime permission from the user.

### WiFi
The following entitlements needed for full operation:
* com.apple.developer.networking.HotspotHelper
* com.apple.developer.networking.wifi-info 

The HotspotHelper entitlement can only be acquired if Apple approves your application (available at [Apple HotspotHelper Request](https://developer.apple.com/contact/request/hotspot-helper/)).

## Development notes
The core of the library is the TrapManager class. It manages the individual colllectors, which are available to the end developer. The other aspect is the data frame transport system, which is an endlessly repeating task with a configurable interval. The reporting task sends the data packets to the specified endpoint. The connection between the two aspects is a memory data store, which is implemented via a custom ring queue.

The goal of the implementation is low and predictably flat resource usage. Therefore on the critical UI path we attempted to avoid allocation and processing as much as possible. The processing part is mostly happening on a background thread. For this we use OperationQueues.

## Legal Warning
Many of the data types collected by this library is capable of identifying the individual user, therefore the integrating app can be affected by GDPR and/or CCPA. You are solely responsible for the data collected and processed via this library.

## License
Licensed under the MIT license.
