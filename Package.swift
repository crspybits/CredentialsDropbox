// swift-tools-version:5.0
// Adapted from https://github.com/IBM-Swift/Kitura-CredentialsGoogle

import PackageDescription

let package = Package(
    name: "CredentialsDropbox",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CredentialsDropbox",
            targets: ["CredentialsDropbox"]
        )
    ],
    dependencies: [
            //.package(url: "../Kitura-Credentials", .branch("master")),
            // .package(url: "https://github.com/crspybits/Kitura-Credentials.git", .branch("master")),
            .package(url: "https://github.com/Kitura/Kitura-Credentials.git", from: "2.5.0")
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CredentialsDropbox",
            dependencies: ["Credentials"]
        )
    ]
)
