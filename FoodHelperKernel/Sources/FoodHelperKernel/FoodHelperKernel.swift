// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

/// Service definition.
public protocol FoodHelperKernel: Sendable {

    /// Get all known recipes.
    /// - Returns: all know recipes.
    func getAllRecipes() async throws(FoodHelperKernelError) -> [Recipe]

    /// Get a single recipe by its unique identifier.
    /// - Parameter id: The unique identifier of the recipe.
    /// - Returns: The recipe matching the specified id, or nil if no such recipe exists.
    func getRecipeById(id: UUID) async throws(FoodHelperKernelError) -> Recipe?

    /// Add a new recipe.
    /// - Parameter recipe: The recipe to add.
    func addRecipe(recipe: Recipe) async throws(FoodHelperKernelError)

    /// Delete a recipe by its unique identifier.
    /// - Parameter id: The unique identifier of the recipe.
    func deleteRecipeById(id: UUID) async throws(FoodHelperKernelError)
}
