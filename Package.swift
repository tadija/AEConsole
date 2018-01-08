// swift-tools-version:4.0

/**
 *  https://github.com/tadija/AELog
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AEConsole",
    products: [
        .library(name: "AEConsole", targets: ["AEConsole"])
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AELog.git", .upToNextMinor(from: "0.5.0"))
    ],
    targets: [
        .target(
            name: "AEConsole",
            dependencies: [
                "AELog"
            ],
            path: "Sources"
        )
    ]
)
