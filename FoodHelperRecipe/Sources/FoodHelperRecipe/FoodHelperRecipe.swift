// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel

public protocol FoodHelperRecipe: Sendable {

    /// Get all known recipes.
    /// - Returns: all know recipes.
    func getAll() async throws(FoodHelperRecipeError) -> [Recipe]

    /// Get a single recipe by its unique identifier.
    /// - Parameter id: The unique identifier of the recipe.
    /// - Returns: The recipe matching the specified id, or nil if no such recipe exists.
    func getById(id: UUID) async throws(FoodHelperRecipeError) -> Recipe?

    /// Add a new recipe.
    /// - Parameter recipe: The recipe to add.
    func add(recipe: Recipe) async throws(FoodHelperRecipeError)

    /// Delete a recipe by its unique identifier.
    /// - Parameter id: The unique identifier of the recipe.
    func deleteById(id: UUID) async throws(FoodHelperRecipeError)
}
