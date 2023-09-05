import Foundation

internal class TrapFileCache {
    /// The FileManager default we use throughout this class
    private let manager = FileManager.default

    /// The url for the cache directory.
    private let directoryURL: URL

    /// The maximum size of the file cache
    private let cacheSize: UInt64

    /// Create a new instance of the file system cache. It returns
    /// nil if there was a file system error.
    public init?(maxSize: UInt64 = 5_000_000) {
        cacheSize = maxSize

        let directory = try? manager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("trap")

        if directory == nil {
            return nil
        } else {
            directoryURL = directory!
        }

        if !manager.fileExists(atPath: directoryURL.absoluteString) {
            do {
                try manager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                return nil
            }
        }
    }

    /// Save a new element at the end  of the cache.
    public func push(data: String) throws {
        try cleanup()

        let file = directoryURL.appendingPathComponent(UUID().uuidString)
        try data.write(to: file, atomically: true, encoding: String.Encoding.utf8)
    }

    /// Get references to all the cached records.
    public func getAll() throws -> [Record] {
        let targets = try files()

        return targets.map { Record($0.0) }
    }

    /// Clean up the cache, i.e. if it's over the indicated capacity, it removes
    /// the oldest files in the cache until the total size is under that amout.
    private func cleanup() throws {
        let targets = try files()
        var total: UInt64 = 0

        try targets.forEach { file in
            total += file.1
            if total > cacheSize {
                try FileManager.default.removeItem(atPath: file.0)
            }
        }
    }

    private func urlToPath(url: URL) -> String {
        
        if #available(iOS 16.0, *) {
            return url.path()
        } else {
            return url.path
        }
    }

    /// Return all files in the cache.
    private func files() throws -> [(String, UInt64, Date)] {
        let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        var targets = try contents.map {
            let file = urlToPath(url: $0)
            let attr = try FileManager.default.attributesOfItem(atPath: file)
            let date = attr[FileAttributeKey.creationDate] as? Date ?? Date()
            let size = attr[FileAttributeKey.size] as? UInt64 ?? UInt64.max

            return (file, size, date)
        }

        targets.sort(by: { $0.2 < $1.2 })

        return targets
    }
}

internal struct Record {
    let file: String

    init(_ file: String) {
        self.file = file
    }

    public func delete() throws {
        try FileManager.default.removeItem(atPath: file)
    }

    public func content() throws -> String {
        try String(contentsOf: URL(fileURLWithPath: file), encoding: .utf8)
    }
}
