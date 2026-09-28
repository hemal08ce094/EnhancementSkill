// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EnhancementSkill",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2)],
    products: [
        .library(name: "HumanTouch", targets: ["HumanTouch"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hemal08ce094/DesignSkillsSwiftUI", from: "0.1.0"),
        .package(url: "https://github.com/hemal08ce094/ThinkingOrbsSwiftUI", from: "0.2.1"),
        .package(url: "https://github.com/hemal08ce094/BotAvatarsSwiftUI", from: "0.1.0"),
        .package(url: "https://github.com/hemal08ce094/DrawablySwiftUI", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "HumanTouch",
            dependencies: [
                .product(name: "DesignSkills", package: "DesignSkillsSwiftUI"),
                .product(name: "ThinkingOrbs", package: "ThinkingOrbsSwiftUI"),
                .product(name: "Drawably", package: "DrawablySwiftUI"),
                // BotAvatars ships for iOS and visionOS only.
                .product(name: "BotAvatars", package: "BotAvatarsSwiftUI", condition: .when(platforms: [.iOS, .visionOS])),
            ]
        ),
        .testTarget(name: "HumanTouchTests", dependencies: ["HumanTouch"]),
    ]
)
