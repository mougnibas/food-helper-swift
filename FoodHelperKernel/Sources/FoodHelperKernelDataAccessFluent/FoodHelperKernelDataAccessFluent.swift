// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Fluent

import FoodHelperKernel
import FoodHelperKernelDataAccess

public actor FoodHelperKernelDataAccessFluent: FoodHelperKernelDataAccess {

    /// Fluent database to use.
    var database: Database

    public init(_ database: Database) async throws {

        // Reference database instance.
        self.database = database
    }

    public func getIdentifiers() async throws(FoodHelperKernelDataAccessError) -> [UUID] {

        do {
            return try await database.transaction { transaction in
                // Get all identifiers.
                let identifiers = try await RecipeModel.query(on: transaction).all(\.$id)

                // Return all identifiers.
                return identifiers
            }
        } catch {
            throw .cantAccessData
        }
    }

    public func getByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) -> Recipe? {

        do {
            return try await database.transaction { transaction in
                // Try fo find the recipe, eager load the steps.
                guard let recipeModel = try await ( RecipeModel
                    .query(on: transaction)
                    .filter(\.$id == id)
                    .with(\.$steps) { stepQuery in
                        stepQuery.with(\.$foods)
                    }
                    .first()
                ) else {
                    return nil
                }

                // Conversion from fluent model to domain model.
                let recipe = recipeModel.convert()

                // Return the recipe
                return recipe
            }
        } catch {
            throw .cantAccessData
        }
    }

    public func createOrUpdate(_ recipe: Recipe) async throws(FoodHelperKernelDataAccessError) {

        do {
            try await database.transaction { transaction in
                // Try fo find the recipe.
                let existingModel = try await RecipeModel.find(recipe.id, on: transaction)

                // If the recipe is not found, create it and add it.
                if existingModel == nil {
                    // Level 1 : recipe.
                    let recipeModel = RecipeModel(recipe)
                    try await recipeModel.create(on: transaction)
                    let recipeId = try recipeModel.requireID()

                    for (indexStep, step) in recipe.steps.enumerated() {
                        // Level 2 : steps
                        let stepModel = StepModel(step, recipeId, indexStep)
                        try await stepModel.create(on: transaction)
                        let stepId = try stepModel.requireID()

                        // Level 3 : foods
                        for (indexFood, food) in step.foods.enumerated() {
                            let foodModel = FoodModel(food, stepId, indexFood)
                            try await foodModel.create(on: transaction)
                        }
                    }
                }
                // Else, update it state, then save it.
                else {
                    existingModel!.update(recipe)
                    try await existingModel!.save(on: transaction)
                }
            }
        } catch {
            throw .cantAccessData
        }
    }

    public func deleteByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) {

        do {
            try await database.transaction { transaction in
                // Try to find the recipe.
                guard let existingModel = try await RecipeModel.find(id, on: transaction) else {
                    return
                }

                // Delete fetched model.
                try await existingModel.delete(on: transaction)
            }
        } catch {
            throw .cantAccessData
        }
    }
}
