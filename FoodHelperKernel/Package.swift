// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    // Name of the package.
    name: "FoodHelperKernel",

    // Can run only on this platform.
    // This "requirement" is actually only for SwiftLint.
    platforms: [
        .macOS(.v12)
    ],

    // This is a library product.
    products: [
        .library(name: "FoodHelperKernel", targets: ["FoodHelperKernel"]),
        .library(name: "FoodHelperKernelClient", targets: ["FoodHelperKernelClient"]),
        .library(name: "FoodHelperKernelDataAccess", targets: ["FoodHelperKernelDataAccess"]),
        .library(name: "FoodHelperKernelDataAccessInMemory", targets: ["FoodHelperKernelDataAccessInMemory"]),
        .library(name: "FoodHelperKernelDataAccessFluent", targets: ["FoodHelperKernelDataAccessFluent"]),
        .library(name: "FoodHelperKernelImpl", targets: ["FoodHelperKernelImpl"]),
        .executable(name: "FoodHelperKernelWebservice", targets: ["FoodHelperKernelWebservice"])
    ],

    // This package declare these dependencies.
    dependencies: [

        // SwiftLint (code style).
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.63.0"),

        // Vapor (swift http framework).
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.121.0"),

        // Vapor Fluent with drivers (swift ORM).
        .package(url: "https://github.com/vapor/fluent.git", exact: "4.13.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", exact: "4.8.1"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", exact: "4.8.0")
    ],

    // We have the following targets.
    targets: [

        // Main public service, with tests.
        .target(
            name: "FoodHelperKernel",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestUnit",
            dependencies: ["FoodHelperKernel"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Caller implementation, with tests.
        .target(
            name: "FoodHelperKernelClient",
            dependencies: ["FoodHelperKernel"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsClientUnit",
            dependencies: [
                "FoodHelperKernelClient"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsClientIntegration",
            dependencies: [
                "FoodHelperKernelClient",
                "FoodHelperKernelWebservice",
                .product(name: "VaporTesting", package: "vapor")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsClientEndToEnd",
            dependencies: [
                "FoodHelperKernelClient"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Data access.
        .target(
            name: "FoodHelperKernelDataAccess",
            dependencies: ["FoodHelperKernel"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Data access (in-memory implementation), with tests.
        .target(
            name: "FoodHelperKernelDataAccessInMemory",
            dependencies: [
                "FoodHelperKernelDataAccess"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsDataAccessInMemoryUnit",
            dependencies: ["FoodHelperKernelDataAccessInMemory"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Data access (fluent implementation).
        .target(
            name: "FoodHelperKernelDataAccessFluent",
            dependencies: [
                "FoodHelperKernelDataAccess",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsDataAccessFluentIntegration",
            dependencies: [
                "FoodHelperKernelDataAccessFluent",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Internal implementation, with tests.
        .target(
            name: "FoodHelperKernelImpl",
            dependencies: [
                "FoodHelperKernel",
                "FoodHelperKernelDataAccess"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestImplUnit",
            dependencies: [
                "FoodHelperKernelImpl",
                "FoodHelperKernelDataAccessInMemory"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),

        // Webservice, with tests.
        .executableTarget(
            name: "FoodHelperKernelWebservice",
            dependencies: [
                "FoodHelperKernelImpl",
                "FoodHelperKernelDataAccessFluent",
                "FoodHelperKernelDataAccessInMemory",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsWebserviceIntegration",
            dependencies: [
                "FoodHelperKernelWebservice",
                .product(name: "VaporTesting", package: "vapor")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "FoodHelperKernelTestsWebserviceEndToEnd",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        )
    ]
)
