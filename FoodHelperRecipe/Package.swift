// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    // Name of the package.
    name: "FoodHelperRecipe",

    // Can run only on this platform.
    // This "requirement" is actually only for SwiftLint.
    platforms: [
        .macOS(.v12)
    ],

    // This is a library product.
    products: [
        .library(   name: "FoodHelperRecipe",           targets: ["FoodHelperRecipe"]),
        .library(   name: "FoodHelperRecipeImpl",       targets: ["FoodHelperRecipeImpl"]),
        .executable(name: "FoodHelperRecipeWebservice", targets: ["FoodHelperRecipeWebservice"])
    ],

    // This package declare these dependencies.
    dependencies: [

        // SwiftLint (code style).
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins",   exact: "0.63.0"),

        // Kernel.
        .package(path: "../FoodHelperKernel"),

        // Vapor (swift http framework).
        .package(url: "https://github.com/vapor/vapor.git",                exact: "4.121.0"),

        // Vapor Fluent with drivers (swift ORM).
        .package(url: "https://github.com/vapor/fluent.git",               exact: "4.13.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", exact: "4.8.1")
    ],

    // We have the following targets.
    targets: [

        // Main public service.
        .target(
            name: "FoodHelperRecipe",
            dependencies: [
                .product(name: "FoodHelperKernel",                   package: "FoodHelperKernel"),
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),

        // Internal implementation, with tests.
        .target(
            name: "FoodHelperRecipeImpl",
            dependencies: [
                "FoodHelperRecipe"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperRecipeTestImplUnit",
            dependencies: [
                "FoodHelperRecipeImpl",
                .product(name: "FoodHelperKernel",                   package: "FoodHelperKernel"),
                .product(name: "FoodHelperKernelImpl",               package: "FoodHelperKernel"),
                .product(name: "FoodHelperKernelDataAccessInMemory", package: "FoodHelperKernel")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),

        // Webservice, with tests.
        .executableTarget(
            name: "FoodHelperRecipeWebservice",
            dependencies: [
                "FoodHelperRecipeImpl",
                .product(name: "FoodHelperKernelDataAccessInMemory", package: "FoodHelperKernel"),
                .product(name: "FoodHelperKernelImpl",               package: "FoodHelperKernel"),
                .product(name: "FoodHelperKernelClient",             package: "FoodHelperKernel"),
                .product(name: "Vapor", package: "vapor")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperRecipeTestsWebserviceUnit",
            dependencies: [
                "FoodHelperRecipeWebservice",
                .product(name: "VaporTesting",                       package: "vapor")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperRecipeTestsWebserviceIntegration",
            dependencies: [
                "FoodHelperRecipeWebservice",
                .product(name: "FoodHelperKernelDataAccessFluent",   package: "FoodHelperKernel"),
                .product(name: "VaporTesting",                       package: "vapor"),
                .product(name: "Fluent",                             package: "fluent"),
                .product(name: "FluentSQLiteDriver",                 package: "fluent-sqlite-driver")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperRecipeTestsWebserviceEndToEnd",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",            package: "SwiftLintPlugins")
            ]
        )
    ]
)
