// swift-tools-version:4.2

/**
 *  https://github.com/tadija/AEConsole
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
        .package(url: "https://github.com/tadija/AELog.git", .upToNextMinor(from: "0.5.6"))
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
