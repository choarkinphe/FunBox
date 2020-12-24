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
            name: "FunNetworking",
            targets: ["FunNetworking"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FunBox",
//            path: "./Sources/FunBox/Core/Code",
            exclude: ["Example","README.MD","LICENSE"]
//            publicHeadersPath: "./Sources/FunBox/Core/Code"
//            sources: ["./Sources/FunBox/Core/Code/FunBox.swift"]
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ]
//            resources: [
//                .copy(".")
//            ]
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
            name: "FunNetworking",
            dependencies: [
                "FunBox",
                "Alamofire"
            ],
//            platforms: [.macOS(.v10_12),
//                        .iOS(.v10),
//                        .tvOS(.v10),
//                        .watchOS(.v3)],
//            path: "./Sources/FunBox/Modules/Networking/Code"
//            platforms: [.iOS]
//            linkerSettings: [.linkedFramework("CFNetwork",
//                                              .when(platforms: [.iOS]))])
            exclude: ["Example","README.MD","LICENSE"]
//            resources: [
//                .copy("."),
//            ]
        ),
//        .target(
//            name: "FunBox",
//            dependencies: []),
        .testTarget(
            name: "FunBoxTests",
            dependencies: ["FunBox","FunUI","FunNetworking"])
    ]
)
