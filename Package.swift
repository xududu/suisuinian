// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "BirthdayLunarSupport",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BirthdayLunarSupport",
            targets: ["BirthdayLunarSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/yuhao09/LunarSwift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "BirthdayLunarSupport",
            dependencies: ["LunarSwift"]),
    ]
)
