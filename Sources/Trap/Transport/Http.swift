import Foundation

/// Sends serialized data via HTTP POST requests.
class TrapHttpTransport: TrapTransport {
    private let url: URL
    private let config: TrapConfig.Reporter

    public init(_ url: URL,_ config: TrapConfig.Reporter) {
        self.url = url
        self.config = config
    }

    func start() {}

    func stop() {}

    func send(data: String, completionHandler: @escaping (Error?) -> Void) {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        let contentTypePostfix = config.compressed ? "+zlib" : ""
        request.setValue(
            "text/plain; encoding=json\(contentTypePostfix)",
            forHTTPHeaderField: "Content-Type")
        request.setValue(
            config.apiKeyValue,
            forHTTPHeaderField: config.apiKeyName)

        var data = data.data(using: .utf8)
        if config.compressed {
            if let uncompressedData = data {
                data = try! NSData(data: uncompressedData).compressed(using: .zlib) as Data
            }
        }
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { _, _, error in
            completionHandler(error)
        }.resume()
    }
}
