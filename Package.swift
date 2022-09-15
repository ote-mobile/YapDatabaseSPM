// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YapDatabaseSPM",
	platforms: [
		.iOS(.v13)
	],
    products: [
        .library(
            name: "YapDatabaseSPM",
            targets: ["YapDatabaseSPM"]
		),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "YapDatabaseSPM",
            path: "export/iOS/YapDatabaseSPM.xcframework"
        )
    ]
)
