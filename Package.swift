// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RPCircularProgress",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "RPCircularProgress",
                 targets: [ "RPCircularProgress" ])
    ],
    dependencies: [],
    targets: [
        .target(name: "RPCircularProgress",
                dependencies: [],
                path: "Source"),
    ]
)
