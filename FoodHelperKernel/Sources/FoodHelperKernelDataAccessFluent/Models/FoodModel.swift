// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Fluent

import FoodHelperKernel

final class FoodModel: Model, @unchecked Sendable {

    /// Name of the table.
    static let schema = "foods"

    /// UUID = 128b = 16B  = BINARY(16) for MySQL.
    @ID(key: .id)
    var id: UUID?

    @Field(key: "index")
    var index: Int

    @Field(key: "name")
    var name: String

    @Field(key: "quantity")
    var quantity: Int

    @Field(key: "unit")
    var unit: UnitMeasurement

    @Parent(key: "step_id")
    var step: StepModel

    /// Default constructor, only for Vapor/Fluent.
    init() {
    }

    init(_ food: Food, _ stepId: UUID, _ index: Int) {

        // Reference root members.
        self.id = UUID()
        self.index = index
        self.name = food.name
        self.quantity = food.quantity
        self.unit = food.unit

        // Reference parent.
        self.$step.id = stepId
    }

    func convert() -> Food {
        return Food(name: name, quantity: quantity, unit: unit)
    }
}
