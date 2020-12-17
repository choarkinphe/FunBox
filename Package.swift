// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FunBox",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FunBox",
            targets: ["Core"]),
        .library(
            name: "FunUI",
            targets: ["UI"]),
        .library(
            name: "FunNetworking",
            targets: ["Networking"])
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
            name: "Core",
            path: "./Sources/FunBox/Core/Code"
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ],
//            resources: [
//                .copy(".")
//            ]
        ),
        .target(
            name: "UI",
            dependencies: [
                "Core"
            ],
            path: "./Sources/FunBox/Modules/UI/Code"
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ],
//            resources: [
//                .copy(".")
//            ]
        ),
        .target(
            name: "Networking",
            dependencies: [
                "Core",
                "Alamofire"
            ],
            path: "./Sources/FunBox/Modules/Networking/Code"
//            exclude: [
//                "mbedtls",
//                "LICENSE"
//            ],
//            resources: [
//                .copy("."),
//            ]
        ),
//        .target(
//            name: "FunBox",
//            dependencies: []),
        .testTarget(
            name: "FunBoxTests",
            dependencies: ["Core","UI","Networking"]),
    ]
)
