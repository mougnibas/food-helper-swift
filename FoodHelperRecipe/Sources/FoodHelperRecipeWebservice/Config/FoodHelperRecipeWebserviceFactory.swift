// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Vapor

import FoodHelperKernel
import FoodHelperKernelImpl
import FoodHelperKernelDataAccess
import FoodHelperKernelDataAccessInMemory
import FoodHelperKernelClient
import FoodHelperRecipe
import FoodHelperRecipeImpl

struct FoodHelperRecipeWebserviceFactory {

    static func configure(_ app: Application) async throws {

        // Service implementation with kernel client.
        let baseURL = Environment.get("KERNEL_BASE_URL") ?? "localhost"
        let kernel = FoodHelperKernelClient(baseURL: URL(string: baseURL)!)
        let service = FoodHelperRecipeImpl(kernel)

        // Generic configuration.
        try await configure(app, service)
    }

    static func configure(_ app: Application, _ service: FoodHelperRecipe) async throws {

        // Ask vapor to produce JSON with :
        // - dictionary keys sorted in lexicographic order
        // - pretty printed
        // - no escale slashes
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        ContentConfiguration.global.use(encoder: encoder, for: .json)

        // Configure server hostname and port.
        // Priorities : environment value > default values
        var port = 8081
        if Environment.get("APP_PORT") != nil {
            let portString = Environment.get("APP_PORT")!
            port = Int(portString)!
        }
        app.http.server.configuration.port = port
        app.http.server.configuration.hostname = Environment.get("APP_HOSTNAME") ?? "0.0.0.0"

        // Create, then register the controller (collection of routes).
        let controller = FoodHelperRecipeWebserviceController(service)
        try app.register(collection: controller)
    }
}
