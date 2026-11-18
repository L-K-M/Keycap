// swift-tools-version: 5.9
import PackageDescription

var package = Package(
    name: "Keycap",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "KeycapCore", targets: ["KeycapCore"]),
    ],
    targets: [
        .target(name: "KeycapCore"),
        .testTarget(name: "KeycapCoreTests", dependencies: ["KeycapCore"]),
    ]
)

// KeycapKit needs AppKit, SwiftUI and Carbon, so it exists only on macOS.
// KeycapCore and KeycapCoreTests build and run everywhere Foundation does.
#if os(macOS)
package.products.append(.library(name: "KeycapKit", targets: ["KeycapKit"]))
package.targets.append(.target(name: "KeycapKit", dependencies: ["KeycapCore"]))
package.targets.append(.testTarget(name: "KeycapKitTests", dependencies: ["KeycapKit"]))
#endif
