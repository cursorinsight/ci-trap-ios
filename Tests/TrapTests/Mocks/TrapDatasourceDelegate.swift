@testable import Trap
import UIKit


public class TrapDatasourceDelegateMock: TrapDatasourceDelegate {
    public init() { }

    public private(set) var saveCallCount = 0
    public var saveHandler: ((Int64, DataType) -> ())?
    public func save(sequence: Int64, data: DataType)  {
        saveCallCount += 1
        if let saveHandler = saveHandler {
            saveHandler(sequence, data)
        }
        
    }
}

