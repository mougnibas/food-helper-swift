// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel

/// Data access service for kernel.
public protocol FoodHelperKernelDataAccess: Sendable {

    /// Retrieves all available recipe identifiers.
    /// - Returns: An array of identifier `UUID` for recipes.
    /// - Throws: An error if the identifiers cannot be fetched.
    func getIdentifiers() async throws(FoodHelperKernelDataAccessError) -> [UUID]

    /// Retrieves a recipe by its unique identifier.
    /// - Parameter id: The `UUID` of the recipe to fetch.
    /// - Returns: The matching `Recipe` if found, otherwise `nil`.
    /// - Throws: An error if the fetch operation fails.
    func getByIdentifier( _ id: UUID) async throws(FoodHelperKernelDataAccessError) -> Recipe?

    /// Create (or update/overrite) a given recipe.
    /// - Parameter recipe: The given recipe.
    /// - Throws: An error if the fetch operation fails.
    func createOrUpdate( _ recipe: Recipe) async throws(FoodHelperKernelDataAccessError)

    /// Delete a recipe by its unique identifier.
    /// - Parameter id: The `UUID` of the recipe to delete.
    /// - Throws: An error if the delete operation fails.
    func deleteByIdentifier( _ id: UUID) async throws(FoodHelperKernelDataAccessError)
}
