// swift-tools-version:5.2

import PackageDescription

var deps: [PackageDescription.Package.Dependency] = []

// The old Swift CI test can't build the docc plugin
// hence the conditional dependency here
#if compiler(>=5.6.0)
    deps.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"))
#endif

let package = Package(
    name: "Trap",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Trap",
            targets: ["Trap"]
        ),
    ],
    dependencies: deps,
    targets: [
        .target(
            name: "Trap",
            path: "Sources"
        ),
        .testTarget(
            name: "TrapTests",
            dependencies: ["Trap"],
            path: "Tests"
        )
    ]
)
