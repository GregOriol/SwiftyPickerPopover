// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftyPickerPopover",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "SwiftyPickerPopover",
            targets: ["SwiftyPickerPopover"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "SwiftyPickerPopover",
            dependencies: [],
            path: "SwiftyPickerPopover",
            exclude: ["Info.plist"],
            resources: [
                .process("Base.lproj"),
                .process("ja.lproj"),
                .process("AbstractPopover.storyboard"),
                .process("ColumnStringPickerPopover.storyboard"),
                .process("DurationPickerPopover.storyboard"),
                .process("PointsPickerPopover.storyboard"),
            ]),
    ],
    swiftLanguageVersions: [.v5]
)
