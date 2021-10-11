// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tabula",
    platforms: [
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
        .library(name: "Tabula", targets: ["Tabula"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Tabula", dependencies: []),
        .testTarget(name: "TabulaTests", dependencies: ["Tabula"]),
    ]
)
