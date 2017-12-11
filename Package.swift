// Adapted from https://github.com/IBM-Swift/Kitura-CredentialsGoogle

import PackageDescription

let package = Package(
    name: "CredentialsDropbox",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura-Credentials.git", majorVersion: 1, minor: 7),
        ]
)
