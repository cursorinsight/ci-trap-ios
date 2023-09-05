import Trap
import SwiftUI

@main
struct ExampleApp: App {
    let trapManager: TrapManager

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    public init() {
        /// Create a new configuration instance.
        var config = Config()

        /// Change what you need to change
        config.reporter.interval = .seconds(3)

        /// Use a HTTP(S) POST endpoint...
        config.reporter.url = "https://example.com/api/post/{sessionId}/{streamId}"

        /// ...or use a (secure) WebSocket endpoint
        config.reporter.url = "wss://example.com/api/ws/{sessionId}/{streamId}"

        trapManager = try! TrapManager(withConfig: config)

        // Run all default collectors...
        try? trapManager.runAll()
    }
}
