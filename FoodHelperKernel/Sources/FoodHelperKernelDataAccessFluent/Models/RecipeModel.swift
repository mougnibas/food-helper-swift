// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Fluent

import FoodHelperKernel

final class RecipeModel: Model, @unchecked Sendable {

    /// Name of the table.
    static let schema = "recipes"

    /// UUID = 128b = 16B  = BINARY(16) for MySQL.
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$recipe)
    var steps: [StepModel]

    /// Default constructor, only for Vapor/Fluent.
    init() {
    }

    /// Create a `RecipeModel`from a `Recipe`.
    /// - Parameter : The recipe.
    init(_ recipe: Recipe) {

        // Reference root members.
        self.id = recipe.id
        self.name = recipe.name
    }

    /// Update the model with the given `Recipe`.
    /// - Parameter : Tje recipe.
    func update(_ recipe: Recipe) {
        self.name = recipe.name
    }

    /// Converts this `RecipeModel` into a `Recipe`.
    /// - Returns: A `Recipe` value constructed from the model's properties.
    func convert() -> Recipe {

        // Order steps by index.
        let sortedStepsModel = self.steps.sorted { $0.index < $1.index }

        // Create steps for the recipe.
        var steps: [Step] = []
        for stepModel in sortedStepsModel {

            // Convert StepModel into Step, then add it to the array.
            let step = stepModel.convert()
            steps.append(step)
        }

        // Convert RecipeModel into Recipe.
        let recipe = Recipe(id: id!, name: name, steps: steps)

        // Return the result.
        return recipe
    }
}
