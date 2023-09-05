import UIKit

/// Transport for data transmission via the websocket protocol.
class TrapWebsocketTransport: TrapTransport {
    private let url: URL
    fileprivate var websocketTask: URLSessionWebSocketTask?

    public init(_ url: URL) {
        self.url = url
    }

    func start() {
        guard websocketTask == nil else {
            return
        }

        let session = URLSession(configuration: .default)
        websocketTask = session.webSocketTask(with: url)
        websocketTask?.resume()
    }

    func stop() {
        websocketTask?.cancel(with: .goingAway, reason: nil)
        websocketTask = nil
    }

    func send(data: String, completionHandler: @escaping @Sendable (Error?) -> Void) {
        Task {
            let message = URLSessionWebSocketTask.Message.string(data)

            websocketTask?.send(message, completionHandler: completionHandler)
        }
    }

    deinit {
        stop()
    }
}

/// Monitor the app lifecycle and disconnect the websocket stream when the app
/// goes into the background and reconnects automatically when the app comes back
/// to the foreground.
class TrapWebsocketForegroundOnlyTransport: TrapWebsocketTransport {
    private var backgroundingObserver: Any?
    private var foregroundingObserver: Any?

    private func connect() {
        super.start()
    }

    private func disconnect() {
        super.stop()
    }

    override func start() {
        let notificationCenter = NotificationCenter.default

        backgroundingObserver = notificationCenter.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let this = self else { return }

            this.disconnect()
        }

        foregroundingObserver = notificationCenter.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let this = self else { return }

            this.connect()
        }

        super.start()
    }

    override func stop() {
        if backgroundingObserver != nil {
            NotificationCenter.default.removeObserver(backgroundingObserver!)
        }
        if foregroundingObserver != nil {
            NotificationCenter.default.removeObserver(foregroundingObserver!)
        }

        super.stop()
    }

    deinit {
        stop()
    }
}

/// A websocket connection which sends a ping control frame in regular intervals
/// if nothing is sent on the channel. It also inherits from the foreground handler
/// websocket stream.
class TrapWSKeepaliveForegroundTransport: TrapWebsocketForegroundOnlyTransport {
    private var timer: Timer?
    private var latestSend = Date()
    private let timeInterval: TimeInterval = 5

    func reconnect() {
        super.stop()
        super.start()
    }

    override func start() {
        super.start()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(ping),
            userInfo: nil,
            repeats: true
        )
    }

    override func stop() {
        timer?.invalidate()
        timer = nil
        super.stop()
    }

    override func send(data: String, completionHandler: @escaping @Sendable (Error?) -> Void) {
        latestSend = Date()
        super.send(data: data) { error in
            if error != nil {
                self.reconnect()
            }

            completionHandler(error)
        }
    }

    @objc public func ping() {
        let diff = Date().timeIntervalSinceReferenceDate - latestSend.timeIntervalSinceReferenceDate
        if diff >= timeInterval {
            websocketTask?.sendPing { [weak self] error in
                guard let this = self else { return }

                if error != nil {
                    // Reconnect on failure to ping
                    this.reconnect()
                }
            }

            latestSend = Date()
        }
    }

    deinit {
        timer?.invalidate()
    }
}
