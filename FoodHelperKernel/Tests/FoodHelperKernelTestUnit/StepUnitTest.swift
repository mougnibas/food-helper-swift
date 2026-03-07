// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing
@testable import FoodHelperKernel

@Suite("Step Model Unit Tests")
struct StepUnitTest {

    @Test("Test full initiliazation")
    func fullInit() async throws {

        // Arrange.
        let title = "My awesome step."
        let instructions = [ "My single instruction." ]
        let foods = [ Food(name: "tomato", quantity: 200, unit: .gram) ]

        // Act.
        let step = Step(title: title, instructions: instructions, foods: foods)

        // Assert.
        #expect(step.title == title)
        #expect(step.instructions == instructions)
        #expect(step.foods == foods)
    }

    @Test("Test equals with identical steps")
    func equalsWithTwoSameSteps() async throws {

        // Arrange.
        let title = "My awesome step."
        let instructions = [ "My single instruction." ]
        let foods = [ Food(name: "tomato", quantity: 200, unit: .gram) ]
        let step1 = Step(title: title, instructions: instructions, foods: foods)
        let step2 = Step(title: title, instructions: instructions, foods: foods)

        // Act and assert.
        #expect(step1 == step2)
    }

    @Test("Test equals with same step")
    func equalsWithSameStep() async throws {

        // Arrange.
        let title = "My awesome step."
        let instructions = [ "My single instruction." ]
        let foods = [ Food(name: "tomato", quantity: 200, unit: .gram) ]
        let step = Step(title: title, instructions: instructions, foods: foods)

        // Act and assert.
        #expect(step == step)
    }

    @Test("Test equals with duplicated step")
    func equalsWithDuplicatedStep() async throws {

        // Arrange.
        let title = "My awesome step."
        let instructions = [ "My single instruction." ]
        let foods = [ Food(name: "tomato", quantity: 200, unit: .gram) ]
        let step1 = Step(title: title, instructions: instructions, foods: foods)
        let step2 = step1

        // Act and assert.
        #expect(step1 == step2)
    }
}
