import Network

/// A transport which can cache messages if send fails
class TrapCachedTransport: TrapTransport {
    private let underlying: TrapTransport
    private let cache: TrapFileCache?

    /// Creates a cached transport instance with the underlying
    /// transport method.
    public init(with transport: TrapTransport, config: Config? = nil) {
        let config = config ?? Config()
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

    func send(data: String, completionHandler handler: @escaping @Sendable (Error?) -> Void) {
        do {
            let cached = try cache?.getAll() ?? []
            if !cached.isEmpty {
                let message = try cached.map {
                    let content = try $0.content()
                    let startIndex = content.index(content.startIndex, offsetBy: 1)
                    let endIndex = content.index(content.endIndex, offsetBy: -2)
                    return content[startIndex..<endIndex]
                }.joined(separator: ",")
                underlying.send(data: "["+message+"]") { error in
                    if error != nil {
                        handler(error)
                    } else {
                        do {
                            try cached.forEach { try $0.delete() }
                        } catch {}
                    }
                }
            }

            underlying.send(data: data) { error in
                if error != nil {
                    try? self.cache?.push(data: data)
                } else {
                    handler(nil)
                }
            }
        } catch {
            handler(error)
        }
    }
}
