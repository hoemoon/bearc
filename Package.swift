// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bearc",
    dependencies: [
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.11.5"),
		.package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
		.package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "bearc",
            dependencies: ["SQLite", "Yams", "Rainbow"]),
        .testTarget(
            name: "bearcTests",
            dependencies: ["bearc"]),
    ]
)
