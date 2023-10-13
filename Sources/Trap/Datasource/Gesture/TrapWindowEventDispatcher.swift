import Foundation
import UIKit

/// A singleton class which receives the events and calls
/// the registered observers on a non-main thread to not hold
/// up the UI thread.
public class TrapWindowEventDispatcher {
    public static let shared = TrapWindowEventDispatcher()
    private var gestureRecognizers = [UIGestureRecognizer]()

    /// Create and initialize the event tracking singleton.
    private init() {}

    /// Add a new observer to the event dispatcher
    public func addGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        let idx = self.gestureRecognizers.firstIndex { $0 === recognizer }
        guard idx == nil else { return }

        self.gestureRecognizers.append(recognizer)
    }

    /// Remove an existing observer from the tracking list.
    public func removeGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        let idx = self.gestureRecognizers.firstIndex { $0 === recognizer }
        guard let nonNilIdx = idx else { return }

        self.gestureRecognizers.remove(at: nonNilIdx)
    }

    /// This method is only called from the private UIWindow extension
    public func sendEvent(_ event: UIEvent) {
        guard !gestureRecognizers.isEmpty else { return }
        if #available(iOS 13.4, *) {
            guard event.type == .scroll || event.type == .hover || event.type == .touches else { return }
        } else {
            guard event.type == .touches else { return }
        }

        if let allTouches = event.allTouches {
            let eventDict = Dictionary(grouping: allTouches, by: { $0.phase })
            eventDict.keys.forEach{ phase in
                if let touches = eventDict[phase] {
                    switch phase {
                        case .began:
                            gestureRecognizers.forEach { $0.touchesBegan(Set(touches), with: event) }
                        case .moved:
                            gestureRecognizers.forEach { $0.touchesMoved(Set(touches), with: event) }
                        case .stationary:
                            gestureRecognizers.forEach { $0.touchesMoved(Set(touches), with: event) }
                        case .ended:
                            gestureRecognizers.forEach { $0.touchesEnded(Set(touches), with: event) }
                        case .cancelled:
                            gestureRecognizers.forEach { $0.touchesCancelled(Set(touches), with: event) }
                        default:
                            break
                    }
                }
            }
       }
    }
}
