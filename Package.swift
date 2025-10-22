// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiiaNetwork",
    platforms: [
        .iOS(.v15), .tvOS(.v10), .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DiiaNetwork",
            targets: ["DiiaNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "5.4.3")),
        .package(url: "https://github.com/DeclarativeHub/ReactiveKit.git", .upToNextMinor(from: "3.16.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DiiaNetwork",
            dependencies: ["Alamofire", "ReactiveKit"]
        ),
        .testTarget(
            name: "DiiaNetworkTests",
            dependencies: ["DiiaNetwork"]
        ),
    ]
)
