import Foundation

/// Sends serialized data via HTTP POST requests.
class TrapHttpTransport: TrapTransport {
    private let url: URL

    public init(_ url: URL) {
        self.url = url
    }

    func start() {}

    func stop() {}

    func send(data: String, completionHandler: @escaping @Sendable (Error?) -> Void) {
        Task {
            var request = URLRequest(url: self.url)
            request.httpMethod = "POST"
            request.setValue("text/plain; encoding=json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data.data(using: .utf8)

            URLSession.shared.dataTask(with: request) { _, _, error in
                completionHandler(error)
            }.resume()
        }
    }
}
