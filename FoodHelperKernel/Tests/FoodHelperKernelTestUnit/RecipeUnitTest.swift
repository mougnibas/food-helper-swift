// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing
@testable import FoodHelperKernel

@Suite("Recipe Model Unit Tests")
struct RecipeUnitTest {

    @Test("Test initialization with only the name")
    func initWithOnlyTheName() async throws {

        // Arrange.
        let name = "Pizza"

        // Act.
        let recipe = Recipe(name: name)

        // Assert.
        #expect(recipe.id != UUID(), "ID should be different from a new UUID")
        #expect(recipe.name == name, "Name should match the one provided")
    }

    @Test("Test initialization with name and id")
    func initWithNameAndId() async throws {

        // Arrange.
        let id = UUID()
        let name = "Pizza"

        // Act.
        let recipe = Recipe(id: id, name: name)

        // Assert.
        #expect(recipe.id == id, "IDs should be equals")
        #expect(recipe.name == name, "Names should be equals")
    }

    @Test("Test initialization with explicit id and name")
    func fullInit() async throws {

        // Arrange.
        let id = UUID()
        let name = "Pizza"
        let steps = [ Step(title: "my step", instructions: ["my instruction"], foods: []) ]

        // Act.
        let recipe = Recipe(id: id, name: name, steps: steps)

        // Assert.
        #expect(recipe.id == id, "IDs should be equals")
        #expect(recipe.name == name, "Names should be equals")
        #expect(recipe.steps == steps, "steps should be equals")
    }

    @Test("Test a new struct with 'pizza' name should be the name 'Pizza'")
    func newRecipePizzaShouldHaveNamePizza() {

        // Arrange.
        let expected = "Pizza"
        let recipe = Recipe(name: expected)

        // Act.
        let actual = recipe.name

        // Assert.
        #expect(actual == expected)
    }

    @Test("Test equals with identical recipes")
    func equalsWithTwoSameRecipes() async throws {

        // Arrange.
        let id = UUID()
        let recipe1 = Recipe(id: id, name: "Pizza")
        let recipe2 = Recipe(id: id, name: "Pizza")

        // Act and assert.
        #expect(recipe1 == recipe2, "Recipes with same id and name should be equal")
    }

    @Test("Test not equals with same name but different id")
    func notEqualsWithSameNameButDifferentId() async throws {

        // Arrange.
        let recipe1 = Recipe(id: UUID(), name: "Pizza")
        let recipe2 = Recipe(id: UUID(), name: "Pizza")

        // Act and assert.
        #expect(recipe1 != recipe2, "Recipes with same name but different ids should not be equal")
    }

    @Test("Test not equals with same id but different name")
    func notEqualsWithSameIdButDifferentName() async throws {

        // Arrange.
        let id = UUID()
        let recipe1 = Recipe(id: id, name: "Pizza")
        let recipe2 = Recipe(id: id, name: "Croissant")

        // Act and assert.
        #expect(recipe1 != recipe2, "Recipes with same id but different names should not be equal")
    }
}
