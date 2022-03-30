// swift-tools-version:5.5

/**
 *  https://github.com/tadija/AEConsole
 *  Copyright © 2016-2022 Marko Tadić
 *  Licensed under the MIT license
 */

import PackageDescription

let package = Package(
    name: "AEConsole",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AEConsole",
            targets: ["AEConsole"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AELog.git", from: "0.6.3")
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
