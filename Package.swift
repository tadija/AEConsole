// swift-tools-version:5.0

/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AEConsole",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "AEConsole",
            targets: ["AEConsole"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AELog.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "AEConsole",
            dependencies: [
                "AELog"
            ]
        )
    ]
)
