// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FoundationICUDemo",
    products: [
        .library(
            name: "FoundationICUDemo",
            targets: ["FoundationICUDemo"]),
    ],
    dependencies: [
        //.package(url: "https://github.com/skiptools/swift-foundation-icu", branch: "main")
        .package(path: "../swift-foundation-icu")
    ],
    targets: [
        .target(
            name: "FoundationICUDemo",
            dependencies: [.product(name: "_FoundationICU", package: "swift-foundation-icu")]),
        .testTarget(
            name: "FoundationICUDemoTests",
            dependencies: ["FoundationICUDemo"]
        ),
    ]
)
