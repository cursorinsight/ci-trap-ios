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

    func send(data: String, avoidSendingTooMuchData: Bool, completionHandler handler: @escaping (Error?) -> Void) {
        do {
            let group = DispatchGroup()
            if !avoidSendingTooMuchData {
                let cached = try cache?.getAll() ?? []
                if !cached.isEmpty {
                    try? cached.forEach { cacheItem in
                        group.enter()
                        let content = try cacheItem.content()
                        underlying.send(data: content, avoidSendingTooMuchData: avoidSendingTooMuchData) { error in
                            if error == nil {
                                do {
                                    try cacheItem.delete()
                                } catch {}
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            group.enter()
            underlying.send(data: data, avoidSendingTooMuchData: avoidSendingTooMuchData) { error in
                if error != nil {
                    try? self.cache?.push(data: data)
                }
                group.leave()
                handler(nil)
            }
        } catch {
            handler(error)
        }
    }
}
