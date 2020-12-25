// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FunBox",
    platforms: [
//        .macOS(.v10_15),
        .iOS(.v10)
//        .tvOS(.v10),
//        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FunBox",
            targets: ["FunBox"]),
        .library(
            name: "FunUI",
            targets: ["FunUI"]),
        .library(
            name: "RxFunBox",
            targets: ["RxFunBox"]),
        .library(
            name: "FunAlamofire",
            targets: ["FunAlamofire"]),
        .library(
            name: "FunWebImage",
            targets: ["FunWebImage"]),
        .library(
            name: "FunMediaHelper",
            targets: ["FunMediaHelper"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "4.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.0")),
        .package(url: "https://github.com/banchichen/TZImagePickerController.git", .upToNextMajor(from: "3.5.8")),
        .package(name: "JXPhotoBrowser", url: "https://github.com/JiongXing/PhotoBrowser.git", .upToNextMajor(from: "3.1.2")),
//        .package(url: "https://github.com/SDWebImage/libwebp-Xcode", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "5.15.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FunBox",
            exclude: ["Example","README.MD","LICENSE"],
            resources: [
                .process("FunBox.xcassets")
            ]
        ),
        .target(
            name: "FunUI",
            dependencies: [
                "FunBox"
            ],
            exclude: ["Example","README.MD","LICENSE"]
//            path: "./Sources/FunBox/Modules/UI/Code",
//            publicHeadersPath: "./Sources/FunBox/Core/Code"
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ]
//            resources: [
//                .copy(".")
//            ]
        ),
        .target(
            name: "RxFunBox",
            dependencies: [
                "FunBox",
                "RxSwift",
                "RxDataSources"
            ],
            exclude: ["Example","README.MD","LICENSE"]
//            path: "./Sources/FunBox/Modules/UI/Code",
//            publicHeadersPath: "./Sources/FunBox/Core/Code"
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ]
//            resources: [
//                .copy(".")
//            ]
        ),
        .target(
            name: "FunAlamofire",
            dependencies: [
                "FunBox",
                "Alamofire"
            ],
//            linkerSettings: [.linkedFramework("CFNetwork",
//                                              .when(platforms: [.iOS]))])
            exclude: ["Example","README.MD","LICENSE"]
//            resources: [
//                .copy("."),
//            ]
        ),
        .target(
            name: "FunWebImage",
            dependencies: [
                "FunBox",
                "Kingfisher"
            ],
//            linkerSettings: [.linkedFramework("CFNetwork",
//                                              .when(platforms: [.iOS]))])
            exclude: ["Example","README.MD","LICENSE"]
//            resources: [
//                .copy("."),
//            ]
        ),
        .target(
            name: "FunMediaHelper",
            dependencies: [
                "FunBox",
                "TZImagePickerController",
                "JXPhotoBrowser"
            ],
//            linkerSettings: [.linkedFramework("CFNetwork",
//                                              .when(platforms: [.iOS]))])
            exclude: ["Example","README.MD","LICENSE"],
            resources: [
                .process("FunBox.xcassets")
            ]
        ),
        .testTarget(
            name: "FunBoxTests",
            dependencies: ["FunBox","FunUI","RxFunBox","FunAlamofire","FunWebImage","FunMediaHelper"])
    ]
)
