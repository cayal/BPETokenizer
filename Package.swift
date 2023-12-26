// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BPETokenizer",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "BPETokenizer",
            targets: ["BPETokenizer"]
        ),
    ],
    targets: [
        .target(
            name: "BPETokenizer",
            swiftSettings: [.enableUpcomingFeature("BareSlashRegexLiterals")]
        ),
        .testTarget(
            name: "BPETokenizerTests",
            dependencies: ["BPETokenizer"],
            resources: [
                .copy("./Resources/special_tokens_map.json"),
                .copy("./Resources/tokenizer.json")]
        ),
    ]
)
