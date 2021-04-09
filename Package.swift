// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tinydux",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Tinydux",
            targets: ["Tinydux"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Promises", url: "https://github.com/google/promises.git", from: "1.2.12"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Tinydux",
            dependencies: ["Promises"]),
        .testTarget(
            name: "TinyduxTests",
            dependencies: ["Tinydux"]),
    ]
)
