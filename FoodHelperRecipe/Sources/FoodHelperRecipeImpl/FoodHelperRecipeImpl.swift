// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel
import FoodHelperRecipe

/// A simple implementation of `FoodHelperRecipe`.
public actor FoodHelperRecipeImpl: FoodHelperRecipe {

    /// Kernel service.
    private let kernel: FoodHelperKernel

    public init(_ kernel: FoodHelperKernel) {

        /// Reference kernel service.
        self.kernel = kernel
    }

    public func getAll() async throws(FoodHelperRecipeError) -> [Recipe] {
        do {
            let recipes = try await kernel.getAllRecipes()
            return recipes
        } catch {
            throw .cantAccessData
        }
    }

    public func getById(id: UUID) async throws(FoodHelperRecipeError) -> Recipe? {
        do {
            let recipe = try await kernel.getRecipeById(id: id)
            return recipe
        } catch {
            throw .cantAccessData
        }
    }

    public func add(recipe: Recipe) async throws(FoodHelperRecipeError) {
        do {
            try await kernel.addRecipe(recipe: recipe)
        } catch {
            throw .cantAccessData
        }
    }

    public func deleteById(id: UUID) async throws(FoodHelperRecipeError) {
        do {
            try await kernel.deleteRecipeById(id: id)
        } catch {
            throw .cantAccessData
        }
    }
}
