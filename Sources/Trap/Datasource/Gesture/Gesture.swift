import UIKit

/// The generic data source for UIKit gestures. The delegate provided required to
/// construct an adequate UIGestureRecognizer for the task and take care of storing
/// the recognition results.
open class TrapGestureCollector {
    public var delegate: TrapDatasourceDelegate?
    private var windowDidBecomeVisibleObserver: Any?
    private var windowDidBecomeHiddenObserver: Any?
    private var recognizers: [Int: [UIGestureRecognizer]]
    public var config: TrapConfig.DataCollection?

    /// Creates a new instance of the generic gesture
    /// recognizer with the specialized delegate.
    public init() {
        recognizers = [Int: [UIGestureRecognizer]]()
    }

    /// Create a gesture recognizer which can be added to the window. A new recognizer
    /// instance MUST be created for every call, otherwise it will not work
    ///
    /// It's an empty function, subclasses must override it.
    public func createRecongizers() -> [UIGestureRecognizer] {
        []
    }

    /// Check for internal window types and return true
    /// if needs to be ignored when gesture recognizers
    /// are registered.
    func filteredForPrivacy(_ window: UIWindow) -> Bool {
        switch true {
        case window.description.starts(with: "<UITextEffectsWindow"):
            return true
        case window.description.starts(with: "<UIRemoteKeyboardWindow"):
            return true
        default:
            return false
        }
    }

    /// Adds a recognizer to a window.
    func addRecognizers(to window: UIWindow) {
        if !filteredForPrivacy(window) {
            guard recognizers[window.hash] != nil else {
                recognizers[window.hash] = createRecongizers()
                for recognizer in recognizers[window.hash]! {
                    window.addGestureRecognizer(recognizer)
                }
                return
            }
        }
    }

    /// Removes a recognizer from a window.
    func removeRecognizers(from window: UIWindow) {
        guard let recognizers = recognizers[window.hash] else {
            return
        }

        for recognizer in recognizers {
            window.removeGestureRecognizer(recognizer)
        }
        self.recognizers.removeValue(forKey: window.hash)
    }

    // MARK: Datasource implementation

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
        self.config = config
        if (config.useGestureRecognizer) {
            subscribeForGestureRecognizer()
        }
        addRecognizersToDispatcher()
    }

    public func stop() {
        if (config?.useGestureRecognizer ?? true) {
            unsubscribeFromGestureRecognizer()
        }
        removeRecognizersFromDispatcher()
    }

    private func addRecognizersToDispatcher() {
        recognizers[-1] = createRecongizers()
        for recognizer in recognizers[-1]! {
            TrapWindowEventDispatcher.shared.addGestureRecognizer(recognizer)
        }
    }

    private func removeRecognizersFromDispatcher() {
        guard let recognizers = recognizers[-1] else {
            return
        }

        for recognizer in recognizers {
            TrapWindowEventDispatcher.shared.removeGestureRecognizer(recognizer)
        }
        self.recognizers.removeValue(forKey: -1)
    }

    private func subscribeForGestureRecognizer() {
        // Register an observer for windows that are becoming visible later
        windowDidBecomeVisibleObserver = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeVisibleNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] notification in
            if case let window? = notification.object as? UIWindow {
                self?.addRecognizers(to: window)
            }
        }

        // Remove the observer for windows that became hidden in the meantime
        windowDidBecomeHiddenObserver = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeHiddenNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] notification in
            if case let window? = notification.object as? UIWindow {
                self?.removeRecognizers(from: window)
            }
        }

        // Finally, add a recognizer to all current windows
        for window in UIApplication.shared.windows {
            if !recognizers.keys.contains(window.hash) {
                addRecognizers(to: window)
            }
        }
    }

    private func unsubscribeFromGestureRecognizer() {
        // Remove the window hidden/visible notifications
        if case let observer? = windowDidBecomeVisibleObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        if case let observer? = windowDidBecomeHiddenObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        // Finally remove all the active recognizers
        for window in UIApplication.shared.windows {
            removeRecognizers(from: window)
        }
    }

    // Automatically stop the collector on deinit.
    deinit {
        stop()
    }
}
