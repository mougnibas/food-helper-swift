// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel
import FoodHelperKernelDataAccess

/// An in-memory implementation of FoodHelperKernelDataAccess.
public final actor FoodHelperKernelDataAccessInMemory: FoodHelperKernelDataAccess {

    /// All known recipes.
    private var recipes: [UUID: Recipe]

    /// Initialize with an optional array of recipes.
    public init() {

        // Empty map.
        recipes = [:]
    }

    public func getIdentifiers() async throws(FoodHelperKernelDataAccessError) -> [UUID] {
        return Array(recipes.keys)
    }

    public func getByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) -> Recipe? {
        return recipes[id]
    }

    public func createOrUpdate(_ recipe: Recipe) async throws(FoodHelperKernelDataAccessError) {
        recipes[recipe.id] = recipe
    }

    public func deleteByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) {
        _ = recipes.removeValue(forKey: id)
    }
}
