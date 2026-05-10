// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FigmaDemoKit",
    platforms: [
        .iOS("26.4"),
        .macOS(.v14),
    ],
    products: [
        .library(name: "AppPreferences",  targets: ["AppPreferences"]),
        .library(name: "GameDomain",      targets: ["GameDomain"]),
        .library(name: "DesignSystem",    targets: ["DesignSystem"]),
        .library(name: "UIComponents",    targets: ["UIComponents"]),
        .library(name: "GameFeature",     targets: ["GameFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.17.0"
        ),
    ],
    targets: [
        .target(name: "AppPreferences", path: "Sources/AppPreferences"),
        .testTarget(
            name: "AppPreferencesTests",
            dependencies: ["AppPreferences"],
            path: "Tests/AppPreferencesTests"
        ),

        .target(name: "GameDomain", path: "Sources/GameDomain"),
        .testTarget(
            name: "GameDomainTests",
            dependencies: ["GameDomain"],
            path: "Tests/GameDomainTests"
        ),

        .target(name: "DesignSystem", path: "Sources/DesignSystem"),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            path: "Tests/DesignSystemTests"
        ),

        .target(
            name: "UIComponents",
            dependencies: ["DesignSystem"],
            path: "Sources/UIComponents"
        ),
        .testTarget(
            name: "UIComponentsTests",
            dependencies: [
                "UIComponents",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Tests/UIComponentsTests"
        ),

        .target(
            name: "GameFeature",
            dependencies: ["AppPreferences", "GameDomain", "DesignSystem", "UIComponents"],
            path: "Sources/GameFeature"
        ),
        .testTarget(
            name: "GameFeatureTests",
            dependencies: ["GameFeature"],
            path: "Tests/GameFeatureTests"
        ),

        .target(
            name: "SettingsFeature",
            dependencies: ["AppPreferences", "DesignSystem", "UIComponents"],
            path: "Sources/SettingsFeature"
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: ["SettingsFeature"],
            path: "Tests/SettingsFeatureTests"
        ),
    ]
)
