import Combine
import Foundation
import UIKit

let metadataEventType = 11

public class TrapMetadataCollector: TrapDatasource {

    public var delegate: TrapDatasourceDelegate?

    private let queue: OperationQueue

    private var reporterTask: Cancellable?

    private var customMap: [String : DataType] = [:]

    public init(withQueue queue: OperationQueue) {
        self.queue = queue
    }

    public func checkConfiguration() -> Bool {
        true // Always OK
    }

    public func checkPermission() -> Bool {
        true // No permission needed
    }

    public func requestPermission(_ success: @escaping () -> Void) {
        success() // Automatically succeeds, no permission needed
    }

    public func start(withConfig config: TrapConfig.DataCollection) {
        reporterTask = queue.schedule(
            after: .init(Date(timeIntervalSinceNow: 1)),
            interval: .seconds(config.metadataSubmissionInterval ?? 60)
        ) { [weak self] in
            guard let this = self else {
                assertionFailure("Metadata task becomes empty while running")
                return
            }
            this.sendMetadataEvent()
        }
    }

    public func stop() {
        reporterTask?.cancel()
    }

    public static func instance(withQueue queue: OperationQueue) -> TrapDatasource {
        TrapMetadataCollector(withQueue: queue)
    }

    public func addCustom(key: String, value: DataType) {
        customMap[key] = value
        sendMetadataEvent()
    }

    public func removeCustom(key: String) {
        customMap.removeValue(forKey: key)
        sendMetadataEvent()
    }

    private func sendMetadataEvent() {
        let timestamp = TrapTime.getCurrentTime()
        delegate?.save(sequence: timestamp, data: DataType.array([
            DataType.int(metadataEventType),
            DataType.int64(timestamp),
            DataType.dict([
                "hardware": hardwareData(),
                "storage": storageData(),
                "custom": customData(),
                "screen": screenData()
            ])
        ]))
    }

    private func customData() -> DataType {
        return DataType.dict(customMap)
    }

    private func hardwareData() -> DataType {
        return DataType.dict([
            "deviceName": DataType.string(UIDevice.current.name),
            "systemName": DataType.string(UIDevice.current.systemName),
            "osVersion": DataType.string(UIDevice.current.systemVersion),
            "model": DataType.string(UIDevice.current.model),
            "modelName": DataType.string(modelName),
            "locale": DataType.string(Locale.current.languageCode ?? "unknown"),
            "uniqueId": DataType.string(UIDevice.current.identifierForVendor?.uuidString ?? "unknown")])
    }

    private func storageData() -> DataType {
        return DataType.dict([
            "totalRAM": DataType.uint64(ProcessInfo.processInfo.physicalMemory),
            "totalDiskSpace": DataType.int64(totalDiskSpaceInBytes),
            "availableDiskSpace": DataType.int64(freeDiskSpaceInBytes)])
    }

    private func screenData() -> DataType {
        let screenBounds = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale

        return DataType.dict([
            "screenScale" : DataType.double(Double(screenScale)),
            "screenHeight" : DataType.double(Double(screenBounds.size.height)),
            "screenWidth" : DataType.double(Double(screenBounds.size.width)),
            "orientation" : DataType.int(orientation)])
    }

    var orientation: Int {
        switch UIDevice.current.orientation {
            case .portrait:
                return 0
            case .portraitUpsideDown:
                return 1
            case .landscapeLeft:
                return 2
            case .landscapeRight:
                return 3
            default:
                return -1
            }
    }

    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space ?? 0
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return "unknown"
    }
}
