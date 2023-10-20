import Network

/// A transport which can cache messages if send fails
class TrapCachedTransport: TrapTransport {
    private let underlying: TrapTransport
    private let cache: TrapFileCache?

    /// Creates a cached transport instance with the underlying
    /// transport method.
    public init(with transport: TrapTransport, config: TrapConfig? = nil) {
        let config = config ?? TrapConfig()
        underlying = transport
        cache = TrapFileCache(maxSize: config.reporter.maxFileCacheSize)

        if cache == nil {
            assertionFailure("File Cache could not be created.")
        }
    }

    func start() {
        underlying.start()
    }

    func stop() {
        underlying.stop()
    }

    func send(data: String, avoidSendingTooMuchData: Bool = false, completionHandler handler: @escaping (Error?) -> Void) {
        do {
            let semaphore = DispatchSemaphore(value: 1)
            if !avoidSendingTooMuchData {
                let cached = try cache?.getAll() ?? []
                if !cached.isEmpty {
                    try? cached.forEach { cacheItem in
                        semaphore.wait()
                        let content = try cacheItem.content()
                        underlying.send(data: content, avoidSendingTooMuchData: avoidSendingTooMuchData) { error in
                            if error == nil {
                                do {
                                    try cacheItem.delete()
                                } catch {}
                            }
                            semaphore.signal()
                        }
                    }
                }
            }
            
            semaphore.wait()
            underlying.send(data: data, avoidSendingTooMuchData: avoidSendingTooMuchData) { error in
                if error != nil {
                    try? self.cache?.push(data: data)
                }
                semaphore.signal()
                handler(error)
            }
        } catch {
            handler(error)
        }
    }
}
