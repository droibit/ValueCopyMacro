// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

private extension PackageDescription.Target.PluginUsage {
    static let swiftLint: Self = .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
}

let debugOtherSwiftFlags = [
    "-Xfrontend", "-warn-long-expression-type-checking=200",
    "-Xfrontend", "-warn-long-function-bodies=200",
    "-strict-concurrency=targeted",
    "-enable-actor-data-race-checks",
]

let package = Package(
    name: "ValueCopyMacro",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],    
    products: [
        .library(
            name: "ValueCopyMacro",
            targets: ["ValueCopyMacro"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            exact: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-07-04-a"
        ),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", exact: "0.51.15"),
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.52.4"),
    ],    
    targets: [
        .target(
            name: "ValueCopyMacro",
            dependencies: [
                "ValueCopyMacroPlugin"
            ],
            swiftSettings: [.unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug))],
             plugins: [
                 .swiftLint,
             ]
        ),
        .macro(
            name: "ValueCopyMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [.unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug))],
            plugins: [
                .swiftLint,
            ]
        ),
        .testTarget(
            name: "ValueCopyMacroPluginTests",
            dependencies: [
                "ValueCopyMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [.unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug))],
            plugins: [
                .swiftLint,
            ]
        ),
    ]
)
