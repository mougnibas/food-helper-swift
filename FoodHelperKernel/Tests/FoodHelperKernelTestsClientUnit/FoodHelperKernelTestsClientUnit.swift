// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

import FoodHelperKernel
@testable import FoodHelperKernelClient

@Suite("FoodHelperKernelClient Unit Tests")
// swiftlint:disable file_length
// swiftlint:disable type_body_length
struct FoodHelperKernelTestsClientUnit {

    @Test("New service should not explode")
    func newServiceShouldNotExplode() async throws {

        // Arrange and act.
        _ = FoodHelperKernelClient()

        // Assert.
        #expect(true)
    }

    @Test("New service with base URL should not explode")
    func newServiceWithBaseUrlShouldNotExplode() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!

        // Act.
        _ = FoodHelperKernelClient(baseURL: baseURL)

        // Assert.
        #expect(true)
    }

    @Test("New service with mock should not explode")
    func newServiceWithMockShouldNotExplode() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()

        // Act.
        _ = FoodHelperKernelClient(baseURL: baseURL, loader: loader)

        // Assert.
        #expect(true)
    }

    // Swift ling rule disable because recipes are long to describe.
    // swiftlint:disable function_body_length
    @Test("Get all recipe should give us this recipe")
    func getAllRecipesShouldReturnThisRecipe() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
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
        let recipes = try await service.getAllRecipes()
        let actual: Recipe = recipes[0]

        // Assert
        #expect(recipes.count == 1)
        #expect(expected == actual)
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    @Test("Get recipe by this ID should return this recipe")
    func getRecipeByIdShouldReturnThisRecipe() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
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
        let actual = try await service.getRecipeById(id: expected.id)

        // Assert.
        #expect(expected == actual)
    }
    // swiftlint:enable function_body_length

    @Test("Get recipe with unknown ID should return nil")
    func getRecipeWithUnknownIdShouldReturnNil() async throws {

        // Arrange.
        let unknownId = UUID(uuidString: "40000000-0000-0000-0000-000000000004")!
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)

        // Act.
        let actual = try? await service.getRecipeById(id: unknownId)

        // Act.
        #expect(actual == nil)
    }

    @Test("Get recipe with this ID should return 500")
    func getRecipeWithUnknownIdShouldReturn500() async throws {

        // Arrange.
        let unknownId = UUID(uuidString: "50000000-0000-0000-0000-000000000000")!
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)

        // Act.
        let actual = try? await service.getRecipeById(id: unknownId)

        // Act.
        #expect(actual == nil)
    }

    @Test("Add a new recipe then getting this new recipe should be the same")
    func addANewRecipeAndGetItShouldBeTheSame() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let expected = Recipe(
            id: UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!,
            name: "Raclette",
            steps: []
        )

        // Act.
        try await service.addRecipe(recipe: expected)
        let actual = try await service.getRecipeById(id: expected.id)

        // Expect.
        #expect(expected == actual)
    }

    @Test("Delete recipe by id should not throw")
    func deleteRecipeByIdShouldNotThrow() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!

        // Act.
        try await service.deleteRecipeById(id: id)

        // Assert.
        #expect(true)
    }

    @Test("Delete recipe by unknown id should not throw")
    func deleteRecipeByUnknownIdShouldNotThrow() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        // Act.
        try await service.deleteRecipeById(id: unknownId)

        // Assert.
        #expect(true)
    }

    @Test("Get welcome message should return expected string")
    func getWelcomeMessageShouldReturnExpectedString() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let expected = "Welcome to FoodHelperKernelWebservice!"

        // Act.
        let actual = try await service.getWelcomeMessage()

        // Assert.
        #expect(expected == actual)
    }

    @Test("Get health live should return ok")
    func getHealthLiveShouldReturnOK() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let expected = true

        // Act.
        let actual = try await service.getHealthLive()

        // Assert.
        #expect(actual == expected)
    }

    @Test("Get health ready should return ok")
    func getHealthReadyShouldReturnOK() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!
        let loader = MockDataLoader()
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: loader)
        let expected = true

        // Act.
        let actual = try await service.getHealthReady()

        // Assert.
        #expect(expected == actual)
    }

    @Test("Get all recipes should throw with invalid base URL")
    func getAllRecipesShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            _ = try await service.getAllRecipes()
        }
    }

    @Test("Get recipe by id should throw with invalid base URL")
    func getRecipeByIdShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)
        let id = UUID()

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            _ = try await service.getRecipeById(id: id)
        }
    }

    @Test("Add recipe should throw with invalid base URL")
    func addRecipeShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)
        let recipe = Recipe(id: UUID(), name: "Test", steps: [])

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            try await service.addRecipe(recipe: recipe)
        }
    }

    @Test("Delete recipe should throw with invalid base URL")
    func deleteRecipeShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)
        let id = UUID()

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            try await service.deleteRecipeById(id: id)
        }
    }

    @Test("Get welcome message should throw with invalid base URL")
    func getWelcomeMessageShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            _ = try await service.getWelcomeMessage()
        }
    }

    @Test("Get health live should throw with invalid base URL")
    func getHealthLiveShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)

        // Act and assert.
        await #expect(throws: FoodHelperKernelError.cantAccessData) {
            _ = try await service.getHealthLive()
        }
    }

    @Test("Get health ready should return false with invalid base URL")
    func getHealthReadyShouldThrowWithInvalidBaseURL() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:1")!
        let service = FoodHelperKernelClient(baseURL: baseURL, loader: URLSession.shared)
        let expected = false

        // Act.
        let actual = try await service.getHealthReady()

        // Assert.
        #expect(expected == actual)
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
