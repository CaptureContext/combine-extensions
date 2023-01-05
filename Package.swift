// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "combine-extensions",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "CombineExtensions",
      type: .static,
      targets: ["CombineExtensions"]
    ),
    .library(
      name: "CombineInterception",
      type: .static,
      targets: ["CombineInterception"]
    ),
    .library(
      name: "CombineRuntime",
      type: .static,
      targets: ["CombineRuntime"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/combine-schedulers.git",
      .upToNextMinor(from: "0.9.1")
    )
  ],
  targets: [
    .target(
      name: "CombineExtensions",
      dependencies: [
        .target(name: "CombineInterception"),
        .target(name: "CombineRuntime"),
        .product(
          name: "CombineSchedulers",
          package: "combine-schedulers"
        ),
      ]
    ),
    .target(
      name: "CombineInterception",
      dependencies: [
        .target(name: "CombineRuntime")
      ]
    ),
    .target(name: "CombineRuntime"),

    // ––––––––––––––––––––––– Tests –––––––––––––––––––––––

    .testTarget(
      name: "CombineExtensionsTests",
      dependencies: [
        .target(name: "CombineExtensions")
      ]
    ),
    .testTarget(
      name: "CombineInterceptionTests",
      dependencies: [
        .target(name: "CombineInterception")
      ]
    ),
  ]
)
