// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Fluent

import FoodHelperKernel

final class StepModel: Model, @unchecked Sendable {

    /// Name of the table.
    static let schema = "steps"

    /// UUID = 128b = 16B  = BINARY(16) for MySQL.
    @ID(key: .id)
    var id: UUID?

    @Field(key: "index")
    var index: Int

    @Field(key: "title")
    var title: String

    @Field(key: "instructions")
    var instructions: [String]

    @Parent(key: "recipe_id")
    var recipe: RecipeModel

    @Children(for: \.$step)
    var foods: [FoodModel]

    /// Default constructor, only for Vapor/Fluent.
    init() {
    }

    init(_ step: Step, _ recipeId: UUID, _ index: Int) {

        // Reference root members.
        self.id = UUID()
        self.index = index
        self.title = step.title
        self.instructions = step.instructions

        // Reference parent.
        self.$recipe.id = recipeId
    }

    func convert() -> Step {

        // Order foods
        let sortedFoodsModel = self.foods.sorted { $0.index < $1.index }

        // Convert FoodModel into Food.
        let foods = sortedFoodsModel.map { $0.convert() }

        // Convert StepModel into Step.
        let step = Step(title: title, instructions: instructions, foods: foods)

        // Return the resut.
        return step
    }
}
