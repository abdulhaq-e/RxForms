// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxForms",
    products: [
        .library(
            name: "RxForms",
            targets: ["RxForms"]),
        // .library(name: "RxForms
    ],
    dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "RxForms",
            dependencies: ["RxSwift", "RxCocoa", "RxRelay"]),
        .testTarget(
            name: "RxFormsTests",
            dependencies: ["RxForms"]),
    ]
)
