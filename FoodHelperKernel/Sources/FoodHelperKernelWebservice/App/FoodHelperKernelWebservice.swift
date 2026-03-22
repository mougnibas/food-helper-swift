// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Vapor
import Logging

@main
enum FoodHelperKernelWebservice {
    static func main() async throws {

        // Get the environment.
        var env: Environment = try Environment.detect()

        // Create logging.
        try LoggingSystem.bootstrap(from: &env)

        // Create Vapor Application.
        let app = try await Application.make(env)

        do {

            // Configure the application using the provided factory.
            try await FoodHelperKernelWebserviceFactory.configure(app)

            // Let start the application.
            try await app.execute()

        } catch {

            // Handle error and vapor shutdown.
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        // Application lifecycle ended.
        // Gracefully stop it.
        try await app.asyncShutdown()
    }
}
