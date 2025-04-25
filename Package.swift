// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorSecureStoragePlugin",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorSecureStoragePlugin",
            targets: ["SecureStoragePlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "6.0.0"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper.git", exact: "4.0.1")
    ],
    targets: [
        .target(
            name: "SecureStoragePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")
            ],
            path: "ios/Sources"
        ),
        .testTarget(
            name: "GenericOAuth2PluginTests",
            dependencies: ["SecureStoragePlugin"],
            path: "ios/Tests"
        )
    ]
)