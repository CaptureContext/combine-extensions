// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "combine-extensions",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "CombineExtensions",
			type: .static,
			targets: ["CombineExtensions"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/combine-interception.git",
			.upToNextMajor(from: "0.2.0")
		),
		.package(
			url: "https://github.com/pointfreeco/combine-schedulers.git",
			.upToNextMajor(from: "1.0.0")
		),
	],
	targets: [
		.target(
			name: "CombineExtensions",
			dependencies: [
				.product(
					name: "CombineInterception",
					package: "combine-interception"
				),
				.product(
					name: "CombineSchedulers",
					package: "combine-schedulers"
				),
			]
		),

		// ––––––––––––––––––––––– Tests –––––––––––––––––––––––

			.testTarget(
				name: "CombineExtensionsTests",
				dependencies: [
					.target(name: "CombineExtensions")
				]
			)
	]
)
