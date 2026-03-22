// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Vapor
import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver

import FoodHelperKernelDataAccess
import FoodHelperKernelDataAccessInMemory
import FoodHelperKernelDataAccessFluent
import FoodHelperKernelImpl

struct FoodHelperKernelWebserviceFactory {

    static func configure(_ app: Application) async throws {

        // Ask vapor to produce JSON with :
        // - dictionary keys sorted in lexicographic order
        // - pretty printed
        // - no escale slashes
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        ContentConfiguration.global.use(encoder: encoder, for: .json)

        // Configure server hostname and port.
        // Priorities : environment value > default values
        app.http.server.configuration.hostname = Environment.get("APP_HOSTNAME") ?? "0.0.0.0"
        app.http.server.configuration.port = Environment.get("APP_PORT").flatMap(Int.init) ?? 8080

        // Configure (dynamically) the database (if needed).
        // Also create the appropriate data access service implementation.
        var data: FoodHelperKernelDataAccess

        switch app.environment {

        case .development:
            data = FoodHelperKernelDataAccessInMemory()

        case .testing:
            try await configureSQLiteInMemoryDatabase(app)
            app.migrations.add(Migration000())
            try await app.autoMigrate()
            data = try await FoodHelperKernelDataAccessFluent(app.db)

        case .production, _:
            try await configureMySQLDatabase(app)
            app.migrations.add(Migration000())
            try await app.autoMigrate()
            data = try await FoodHelperKernelDataAccessFluent(app.db)
        }

        // Data access and service implementation.
        let service = try await FoodHelperKernelImpl(dataAccess: data)

        // Create, then register the controller (collection of routes).
        let controller = FoodHelperKernelWebserviceController(service)
        try app.register(collection: controller)
    }

    static func configure(_ app: Application, _ data: FoodHelperKernelDataAccess) async throws {

        // Ask vapor to produce JSON with :
        // - dictionary keys sorted in lexicographic order
        // - pretty printed
        // - no escale slashes
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        ContentConfiguration.global.use(encoder: encoder, for: .json)

        // Configure server hostname and port.
        // Priorities : environment value > default values
        app.http.server.configuration.hostname = Environment.get("APP_HOSTNAME") ?? "0.0.0.0"
        app.http.server.configuration.port = Environment.get("APP_PORT").flatMap(Int.init) ?? 8080

        // Data access and service implementation.
        let service = try await FoodHelperKernelImpl(dataAccess: data)

        // Create, then register the controller (collection of routes).
        let controller = FoodHelperKernelWebserviceController(service)
        try app.register(collection: controller)
    }

    private static func configureMySQLDatabase(_ app: Application) async throws {

        // Get the environemt variables.
        // Priorities : environment value > default values
        let dbHostname = Environment.get("DB_HOSTNAME") ?? "0.0.0.0"
        let dbUsername = Environment.get("DB_USERNAME") ?? "kernel-db-user"
        let dbPassword = Environment.get("DB_PASSWORD") ?? "kernel-db-password"
        let dbDatabase = Environment.get("DB_DATABASE") ?? "kernel-db"

        // Configure a MySQL database.
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.certificateVerification = .none
        app.databases.use(.mysql(
            hostname: dbHostname,
            username: dbUsername,
            password: dbPassword,
            database: dbDatabase,
            tlsConfiguration: tls
        ), as: .mysql)
    }

    private static func configureSQLiteInMemoryDatabase(_ app: Application) async throws {

        // Configure a SQLite (in memory) database.
        app.databases.use(.sqlite(.memory), as: .sqlite)
    }
}
