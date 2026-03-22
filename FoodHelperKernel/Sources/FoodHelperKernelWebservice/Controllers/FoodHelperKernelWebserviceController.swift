// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Vapor
import RoutingKit
import FoodHelperKernel

struct FoodHelperKernelWebserviceController: RouteCollection {

    // Service to use.
    let service: any FoodHelperKernel

    init(_ service: any FoodHelperKernel) {
        self.service = service
    }

    func boot(routes: any RoutesBuilder) throws {

        // GET
        routes.get { _ in
            "Welcome to FoodHelperKernelWebservice!"
        }

        // GET /health/live
        routes.get("health", "live", use: getHealthLive)

        // GET /health/ready
        routes.get("health", "ready", use: getHealthReady)

        // GET /kernel/recipe
        routes.get("kernel", "recipe", use: getRecipes)

        // GET /kernel/recipe/{uuid}
        routes.get("kernel", "recipe", ":uuid", use: getRecipeById)

        // DELETE /kernel/recipe/{uuid}
        routes.delete("kernel", "recipe", ":uuid", use: deleteRecipeById)

        // POST /kernel/recipe
        routes.post("kernel", "recipe", use: postRecipe)
    }

    func getHealthLive(req: Request) async throws -> HTTPStatus {
        return .ok
    }

    func getHealthReady(req: Request) async throws -> HTTPStatus {
        do {
            _ = try await service.getAllRecipes()
            return .ok
        } catch {
            return .serviceUnavailable
        }
    }

    func getRecipes(req: Request) async throws -> [Recipe] {

        // Get all recipes.
        let recipes = try await service.getAllRecipes()

        // Return all recipes.
        return recipes
    }

    func getRecipeById(req: Request) async throws -> Recipe {

        // Get the UUID as parameter.
        guard let uuid = req.parameters.get("uuid", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // Get the recipe (if any), by uuid, from service.
        guard let recipe = try await service.getRecipeById(id: uuid) else {
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
        try await service.deleteRecipeById(id: uuid)
        return .noContent
    }

    func postRecipe(req: Request) async throws -> Response {

        // Get the recipe to create.
        guard let recipe = try? req.content.decode(Recipe.self) else {
            throw Abort(.badRequest)
        }

        // Add the recipe.
        try await service.addRecipe(recipe: recipe)

        // Build the response, then return it.
        let response = Response(status: .created)
        response.headers.add(
            name: .location,
            value: "/kernel/recipe/\(recipe.id)"
        )
        return response
    }
}
