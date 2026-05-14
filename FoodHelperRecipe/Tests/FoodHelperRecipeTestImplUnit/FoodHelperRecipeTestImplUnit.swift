// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

import FoodHelperKernel
import FoodHelperKernelDataAccessInMemory
import FoodHelperKernelImpl
import FoodHelperRecipe
@testable import FoodHelperRecipeImpl

private actor FailingKernel: FoodHelperKernel {

    private var addCallCount = 0
    private var getByIdentifierCallCount = 0

    private let kernel: FoodHelperKernelImpl

    init() async throws {
        self.kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
    }

    func getAllRecipes() async throws(FoodHelperKernelError) -> [Recipe] {
        throw .cantAccessData
    }

    func getRecipeById(id: UUID) async throws(FoodHelperKernelError) -> Recipe? {
        if getByIdentifierCallCount == 0 {
            getByIdentifierCallCount = 1
            return try await kernel.getRecipeById(id: id)
        }

        throw .cantAccessData
    }

    func addRecipe(recipe: Recipe) async throws(FoodHelperKernelError) {
        if addCallCount == 0 {
            addCallCount = 1
            try await kernel.addRecipe(recipe: recipe)
            return
        }

        throw .cantAccessData
    }

    func deleteRecipeById(id: UUID) async throws(FoodHelperKernelError) {
        throw .cantAccessData
    }
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
@Suite("FoodHelperRecipeImpl Unit tests")
struct FoodHelperRecipeTestImplUnit {

    @Test("New service should not explode")
    func newServiceShouldNotExplode() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())

        // Act.
        _ = FoodHelperRecipeImpl(kernel)

        // Assert.
        #expect(true)
    }

    // Swift lint rule disable because recipes are long to describe.
    // swiftlint:disable function_body_length
    @Test("Get all recipe should give us this recipe")
    func getAllRecipesShouldReturnThisRecipe() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let expected = Recipe(
            id: UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!,
            name: "Tartine façon Zoé (Thème Naruto)",
            steps: [
                Step(
                    title: "On prépare la sauce.",
                    instructions: [
                        "Eplucher les oignons.",
                        "Emincer les oignons.",
                        "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                        "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                        "Baisser le feu, puis ajouter les dès de tomates.",
                        "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                        "Réserver la sauce dans un bol."
                    ],
                    foods: [
                        Food(name: "Oignons", quantity: 100, unit: .gram),
                        Food(name: "Huile d'olive", quantity: 20, unit: .gram),
                        Food(name: "Dès de tomates en conserve", quantity: 250, unit: .gram),
                        Food(name: "Sucre", quantity: 30, unit: .gram),
                        Food(name: "Sel", quantity: 10, unit: .gram)
                    ]
                ),
                Step(
                    title: "Ca va raper !",
                    instructions: [
                        "Raper le fromage",
                        "Réserver le fromage rapé dans un bol."
                    ],
                    foods: [
                        Food(name: "Comté", quantity: 200, unit: .gram)
                    ]
                ),
                Step(
                    title: "On prépare le jambon.",
                    instructions: [
                        "Couper grossièrement le jambon blanc.",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Jambon blanc", quantity: 150, unit: .gram)
                    ]
                ),
                Step(
                    title: "Et les olives alors ?",
                    instructions: [
                        "Couper les olives en fines tranches",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Olives noires", quantity: 50, unit: .gram)
                    ]
                ),
                Step(
                    title: "Les (bons ?) champigons de Paris.",
                    instructions: [
                        "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                        "Les couper en tranches moyenne.",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Champignon de Paris", quantity: 100, unit: .gram)
                    ]
                ),
                Step(
                    title: "On découpe le pain.",
                    instructions: [
                        "Trancher le pain en fine tranches.",
                        "Arrondir les angles pour en faire une forme en bandeau.",
                        "Recouvrir une plate de cuisson de papier sulfurisé.",
                        "Répartir les tranches de pains sur la plaque."
                    ],
                    foods: [
                        Food(name: "Pain", quantity: 250, unit: .gram)
                    ]
                ),
                Step(
                    title: "On assemble, c'est bientôt fini.",
                    instructions: [
                        "Etaler la sauce sur les tranches de pains.",
                        "Etaler le jambon blanc.",
                        "Etaler le fromage rapé.",
                        "Etaler les tranches de champignons.",
                        "Etaler les tranches d'olives.",
                        "Disposer les épices pour former le signe du village caché souhaité"
                    ],
                    foods: [
                        Food(name: "Origan", quantity: 10, unit: .gram),
                        Food(name: "Herbes de provence", quantity: 10, unit: .gram)
                    ]
                ),
                Step(
                    title: "Au four !",
                    instructions: [
                        "Faire chauffer le four à chaleur tournante à 180°C.",
                        "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                        "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                        "Sortir du four et laisser légèrement refroidir avant de déguster."
                    ],
                    foods: []
                )
            ]
        )

        // Act.
        let recipes = try await service.getAll()
        let actual: Recipe = recipes[0]

        // Assert
        #expect(recipes.count == 1)
        #expect(expected == actual)
    }
    // swiftlint:enable function_body_length

    // Swift lint rule disable because recipes are long to describe.
    // swiftlint:disable function_body_length
    @Test("Get recipe by this ID should return this recipe")
    func getRecipeByIdShouldReturnThisRecipe() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let expected = Recipe(
            id: UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!,
            name: "Tartine façon Zoé (Thème Naruto)",
            steps: [
                Step(
                    title: "On prépare la sauce.",
                    instructions: [
                        "Eplucher les oignons.",
                        "Emincer les oignons.",
                        "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                        "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                        "Baisser le feu, puis ajouter les dès de tomates.",
                        "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                        "Réserver la sauce dans un bol."
                    ],
                    foods: [
                        Food(name: "Oignons", quantity: 100, unit: .gram),
                        Food(name: "Huile d'olive", quantity: 20, unit: .gram),
                        Food(name: "Dès de tomates en conserve", quantity: 250, unit: .gram),
                        Food(name: "Sucre", quantity: 30, unit: .gram),
                        Food(name: "Sel", quantity: 10, unit: .gram)
                    ]
                ),
                Step(
                    title: "Ca va raper !",
                    instructions: [
                        "Raper le fromage",
                        "Réserver le fromage rapé dans un bol."
                    ],
                    foods: [
                        Food(name: "Comté", quantity: 200, unit: .gram)
                    ]
                ),
                Step(
                    title: "On prépare le jambon.",
                    instructions: [
                        "Couper grossièrement le jambon blanc.",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Jambon blanc", quantity: 150, unit: .gram)
                    ]
                ),
                Step(
                    title: "Et les olives alors ?",
                    instructions: [
                        "Couper les olives en fines tranches",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Olives noires", quantity: 50, unit: .gram)
                    ]
                ),
                Step(
                    title: "Les (bons ?) champigons de Paris.",
                    instructions: [
                        "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                        "Les couper en tranches moyenne.",
                        "Réserver dans un bol."
                    ],
                    foods: [
                        Food(name: "Champignon de Paris", quantity: 100, unit: .gram)
                    ]
                ),
                Step(
                    title: "On découpe le pain.",
                    instructions: [
                        "Trancher le pain en fine tranches.",
                        "Arrondir les angles pour en faire une forme en bandeau.",
                        "Recouvrir une plate de cuisson de papier sulfurisé.",
                        "Répartir les tranches de pains sur la plaque."
                    ],
                    foods: [
                        Food(name: "Pain", quantity: 250, unit: .gram)
                    ]
                ),
                Step(
                    title: "On assemble, c'est bientôt fini.",
                    instructions: [
                        "Etaler la sauce sur les tranches de pains.",
                        "Etaler le jambon blanc.",
                        "Etaler le fromage rapé.",
                        "Etaler les tranches de champignons.",
                        "Etaler les tranches d'olives.",
                        "Disposer les épices pour former le signe du village caché souhaité"
                    ],
                    foods: [
                        Food(name: "Origan", quantity: 10, unit: .gram),
                        Food(name: "Herbes de provence", quantity: 10, unit: .gram)
                    ]
                ),
                Step(
                    title: "Au four !",
                    instructions: [
                        "Faire chauffer le four à chaleur tournante à 180°C.",
                        "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                        "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                        "Sortir du four et laisser légèrement refroidir avant de déguster."
                    ],
                    foods: []
                )
            ]
        )

        // Act.
        let actual = try await service.getById(id: expected.id)

        // Assert.
        #expect(expected == actual)
    }
    // swiftlint:enable function_body_length

    @Test("getRecipeById two time should throw cantAccessData")
    func getRecipeByIdTwoTimeShouldThrowCantAccessData() async throws {

        // Arrange.
        let kernel = try await FailingKernel()
        let service = FoodHelperRecipeImpl(kernel)
        let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
        _ = try await service.getById(id: id)

        // Act and assert.
        await #expect(throws: FoodHelperRecipeError.cantAccessData) {
            _ = try await service.getById(id: id)
        }
    }

    @Test("Get recipe with unknown ID should return nil")
    func getRecipeWithUnknownIdShouldReturnNil() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        // Act.
        let actual = try? await service.getById(id: unknownId)

        // Act.
        #expect(actual == nil)
    }

    @Test("Add a new recipe then getting this new recipe should be the same")
    func addANewRecipeAndGetItShouldBeTheSame() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
        let name = "Raclette"
        let expected = Recipe(id: id, name: name)

        // Act.
        _ = try await service.add(recipe: expected)
        let actual = try await service.getById(id: id)

        // Assert.
        #expect(expected == actual)
    }

    @Test("Delete recipe by id should remove the recipe")
    func deleteRecipeByIdShouldRemoveRecipe() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!

        // Act.
        try await service.deleteById(id: id)
        let actual = try? await service.getById(id: id)

        // Assert.
        #expect(actual == nil)
    }

    @Test("Delete recipe with unknown ID should not throw")
    func deleteRecipeWithUnknownIdShouldNotThrow() async throws {

        // Arrange.
        let kernel = try await FoodHelperKernelImpl(dataAccess: FoodHelperKernelDataAccessInMemory())
        let service = FoodHelperRecipeImpl(kernel)
        let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        // Act.
        try await service.deleteById(id: unknownId)

        // Assert.
        #expect(true)
    }

    @Test("Get all recipes should throw cantAccessData when data access fails")
    func getAllRecipesShouldThrowCantAccessDataWhenDataAccessFails() async throws {

        // Arrange.
        let kernel = try await FailingKernel()
        let service = FoodHelperRecipeImpl(kernel)

        // Act and assert.
        await #expect(throws: FoodHelperRecipeError.cantAccessData) {
            try await service.getAll()
        }
    }

    @Test("Get recipe by id should throw cantAccessData when data access fails")
    func getRecipeByIdShouldThrowCantAccessDataWhenDataAccessFails() async throws {

        // Arrange.
        let kernel = try await FailingKernel()
        let service = FoodHelperRecipeImpl(kernel)
        let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
        _ = try await service.getById(id: id)

        // Act and assert.
        await #expect(throws: FoodHelperRecipeError.cantAccessData) {
            _ = try await service.getById(id: id)
        }
    }

    @Test("Add recipe should throw cantAccessData when data access fails")
    func addRecipeShouldThrowCantAccessDataWhenDataAccessFails() async throws {

        // Arrange.
        let kernel = try await FailingKernel()
        let service = FoodHelperRecipeImpl(kernel)
        let recipe = Recipe(id: UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!, name: "Raclette")
        try await service.add(recipe: recipe)

        // Act and assert.
        await #expect(throws: FoodHelperRecipeError.cantAccessData) {
            try await service.add(recipe: recipe)
        }
    }

    @Test("Delete recipe should throw cantAccessData when data access fails")
    func deleteRecipeShouldThrowCantAccessDataWhenDataAccessFails() async throws {

        // Arrange.
        let kernel = try await FailingKernel()
        let service = FoodHelperRecipeImpl(kernel)
        let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!

        // Act and assert.
        await #expect(throws: FoodHelperRecipeError.cantAccessData) {
            try await service.deleteById(id: id)
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
