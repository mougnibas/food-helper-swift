// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Vapor
import RoutingKit
import FoodHelperRecipe
import FoodHelperKernel

struct FoodHelperRecipeWebserviceController: RouteCollection {

    // Service to use.
    let service: any FoodHelperRecipe

    init(_ service: any FoodHelperRecipe) {
        self.service = service
    }

    func boot(routes: any RoutesBuilder) throws {

        // Guard Middleware for user.
        let routesForUser = routes
            .grouped(UserBasicAuthenticator())
            .grouped(User.guardMiddleware())

        // Guard Middleware for admin.
        let routesForAdmin = routes
            .grouped(AdminBasicAuthenticator())
            .grouped(User.guardMiddleware())

        // GET
        routes.get { _ in
            "Welcome to FoodHelperRecipeWebservice!"
        }

        // GET /health/live
        routes.get("health", "live", use: getHealthLive)

        // GET /health/ready
        routes.get("health", "ready", use: getHealthReady)

        // GET /recipe
        routesForUser.get("recipe", use: getRecipes)

        // GET /recipe/{uuid}
        routesForUser.get("recipe", ":uuid", use: getRecipeById)

        // DELETE /recipe/{uuid}
        routesForAdmin.delete("recipe", ":uuid", use: deleteRecipeById)

        // POST /recipe
        routesForAdmin.post("recipe", use: postRecipe)
    }

    func getHealthLive(req: Request) async throws -> HTTPStatus {
        return .ok
    }

    func getHealthReady(req: Request) async throws -> HTTPStatus {
        do {
            _ = try await service.getAll()
            return .ok
        } catch {
            return .serviceUnavailable
        }
    }

    func getRecipes(req: Request) async throws -> [Recipe] {

        // Get all recipes.
        let recipes = try await service.getAll()

        // Return all recipes.
        return recipes
    }

    func getRecipeById(req: Request) async throws -> Recipe {

        // Get the UUID as parameter.
        guard let uuid = req.parameters.get("uuid", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // Get the recipe (if any), by uuid, from service.
        guard let recipe = try await service.getById(id: uuid) else {
            throw Abort(.notFound)
        }

        // Return the recipe
        return recipe
    }

    func deleteRecipeById(req: Request) async throws -> HTTPStatus {

        // Get the UUID as parameter.
        guard let uuid = req.parameters.get("uuid", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // Delete the recipe, then return response.
        try await service.deleteById(id: uuid)
        return .noContent
    }

    func postRecipe(req: Request) async throws -> Response {

        // Get the recipe to create.
        guard let recipe = try? req.content.decode(Recipe.self) else {
            throw Abort(.badRequest)
        }

        // Add the recipe.
        try await service.add(recipe: recipe)

        // Build the response, then return it.
        let response = Response(status: .created)
        response.headers.add(
            name: .location,
            value: "/recipe/\(recipe.id)"
        )
        return response
    }
}
