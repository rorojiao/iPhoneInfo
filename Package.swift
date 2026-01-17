// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "iPhoneInfo",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "iPhoneInfo",
            targets: ["iPhoneInfo"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "iPhoneInfo",
            dependencies: [],
            path: "iPhoneInfo",
            sources: [
                "App",
                "Views",
                "Services",
                "Models",
                "Benchmark"
            ]
        )
    ]
)
