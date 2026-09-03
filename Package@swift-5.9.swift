// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "combine-extensions",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(
			name: "CombineExtensions",
			type: .static,
			targets: ["CombineExtensions"]
		),
		.library(
			name: "CombineExtensionsMacros",
			type: .static,
			targets: ["CombineExtensionsMacros"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/combine-interception.git",
			.upToNextMinor(from: "0.4.3")
		),
		.package(
			url: "https://github.com/pointfreeco/combine-schedulers.git",
			.upToNextMajor(from: "1.2.2")
		),
		.package(
			url: "https://github.com/pointfreeco/swift-concurrency-extras.git",
			.upToNextMajor(from: "1.4.1")
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
				.product(
					name: "ConcurrencyExtras",
					package: "swift-concurrency-extras"
				),
			]
		),
		.target(
			name: "CombineExtensionsMacros",
			dependencies: [
				.target(name: "CombineExtensions"),
				.product(
					name: "CombineInterceptionMacros",
					package: "combine-interception"
				),
			]
		),
		.testTarget(
			name: "CombineExtensionsTests",
			dependencies: [
				.target(name: "CombineExtensions"),
			]
		),
	]
)
