// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel
import FoodHelperKernelDataAccess

/// A simple implementation of `FoodHelperService`.
public actor FoodHelperKernelImpl: FoodHelperKernel {

    /// Data access layer.
    private let dataAccess: FoodHelperKernelDataAccess

    /// Initialize the service.
    public init(dataAccess: FoodHelperKernelDataAccess) async throws(FoodHelperKernelError) {

        // Reference data access.
        self.dataAccess = dataAccess
    }

    /// Get all known recipes.
    public func getAllRecipes() async throws(FoodHelperKernelError) -> [Recipe] {

        do {
            // Fetch all identifiers first.
            let ids = try await dataAccess.getIdentifiers()

            // Fetch all recipes for those identifiers.
            var recipes: [Recipe] = []
            for id in ids {
                let recipe = try await dataAccess.getByIdentifier(id)
                if let unwrappedRecipe = recipe {
                    recipes.append(unwrappedRecipe)
                }
            }
            return recipes
        } catch {
            throw .cantAccessData
        }
    }

    /// Get a single recipe by its unique identifier.
    public func getRecipeById(id: UUID) async throws(FoodHelperKernelError) -> Recipe? {

        do {
            return try await dataAccess.getByIdentifier(id)
        } catch {
            throw .cantAccessData
        }
    }

    /// Add a new recipe.
    public func addRecipe(recipe: Recipe) async throws(FoodHelperKernelError) {

        do {
            try await dataAccess.createOrUpdate(recipe)
        } catch {
            throw .cantAccessData
        }
    }

    /// Delete a recipe by its unique identifier.
    public func deleteRecipeById(id: UUID) async throws(FoodHelperKernelError) {

        do {
            try await dataAccess.deleteByIdentifier(id)
        } catch {
            throw .cantAccessData
        }
    }
}
