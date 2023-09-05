// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Trap",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Trap",
            targets: ["Trap"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Trap"
        ),
        .testTarget(
            name: "TrapTests",
            dependencies: ["Trap"]
        )
    ]
)
