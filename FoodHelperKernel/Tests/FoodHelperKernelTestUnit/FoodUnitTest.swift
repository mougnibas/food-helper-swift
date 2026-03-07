// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing
@testable import FoodHelperKernel

@Suite("Food Model Unit Tests")
struct FoodUnitTest {

    @Test("Test full initiliazation")
    func fullInit() async throws {

        // Arrange.
        let name = "Tomato"
        let quantity = 200
        let unit = UnitMeasurement.gram

        // Act.
        let food = Food(name: name, quantity: quantity, unit: unit)

        // Assert.
        #expect(food.name == name)
        #expect(food.quantity == quantity)
        #expect(food.unit == unit)
    }

    @Test("Test equals with identical food")
    func equalsWithTwoSameFoods() async throws {

        // Arrange.
        let name = "Tomato"
        let quantity = 200
        let unit = UnitMeasurement.gram
        let food1 = Food(name: name, quantity: quantity, unit: unit)
        let food2 = Food(name: name, quantity: quantity, unit: unit)

        // Act and assert.
        #expect(food1 == food2)
    }

    @Test("Test equals with same food")
    func equalsWithSameFood() async throws {

        // Arrange.
        let name = "Tomato"
        let quantity = 200
        let unit = UnitMeasurement.gram
        let food = Food(name: name, quantity: quantity, unit: unit)

        // Act and assert.
        #expect(food == food)
    }

    @Test("Test equals with duplicated food")
    func equalsWithDuplicatedFood() async throws {

        // Arrange.
        let name = "Tomato"
        let quantity = 200
        let unit = UnitMeasurement.gram
        let food1 = Food(name: name, quantity: quantity, unit: unit)
        let food2 = food1

        // Act and assert.
        #expect(food1 == food2)
    }
}
