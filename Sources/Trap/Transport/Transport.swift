import Combine
import Foundation
import UIKit

/// Implementors seamlessly handle app lifecycle
/// events and transmit the data to the specified endpoint.
/// The implementations handle serialization and session
/// management.
protocol TrapTransport {
    /// Starts up this transport mechanism.
    func start()

    /// Stops this transport mechanism.
    func stop()

    /// Send data packet via this transport mechanism.
    func send(data: String, avoidSendingTooMuchData: Bool, completionHandler: @escaping (Error?) -> Void)
}
