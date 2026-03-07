// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

import FoodHelperKernel
import FoodHelperKernelClient

@Suite("Client end-to-end Tests", .serialized)
// swiftlint:disable type_body_length
struct FoodHelperKernelTestsClientEndToEnd {

    private static let localPort = 8080
    private static let localBaseUrl = URL(string: "http://127.0.0.1:\(localPort)")!

    private let port = FoodHelperKernelTestsClientEndToEnd.localPort
    private var baseUrl = FoodHelperKernelTestsClientEndToEnd.localBaseUrl

    @Test("Default constructor should not explode")
    func defaultConstructorShouldNotExplode() async throws {

        // Arrange and act.
        _ = FoodHelperKernelClient()

        // Assert.
        #expect(true)
    }

    // swiftlint:disable function_body_length
    @Test("getAllRecipes should return all recipes")
    func getAllRecipesShouldReturnAllRecipes() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
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
        let actual = recipes[0]

        // Assert.
        #expect(recipes.count == 1)
        #expect(expected == actual)
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    @Test("Get recipe by this ID should return this recipe")
    func getRecipeByIdShouldReturnThisRecipe() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
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
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        // Act.
        let actual = try? await service.getRecipeById(id: unknownId)

        // Assert.
        #expect(actual == nil)
    }

    @Test("Add a new recipe then getting this new recipe should be the same")
    func addANewRecipeAndGetItShouldBeTheSame() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let id = UUID()
        let name = "Raclette"
        let expected = Recipe(id: id, name: name)

        // Act.
        try await service.addRecipe(recipe: expected)
        let actual = try await service.getRecipeById(id: id)

        // Assert.
        #expect(expected == actual)

        // Cleanup.
        try await service.deleteRecipeById(id: id)
    }

    @Test("Delete recipe by id should remove the recipe")
    func deleteRecipeByIdShouldRemoveRecipe() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let id = UUID()
        let recipe = Recipe(id: id, name: "Raclette")
        try await service.addRecipe(recipe: recipe)

        // Act.
        try await service.deleteRecipeById(id: id)
        let actual = try? await service.getRecipeById(id: id)

        // Assert.
        #expect(actual == nil)
    }

    @Test("Get welcome message should return expected string")
    func getWelcomeMessageShouldReturnExpectedString() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let expected = "Welcome to FoodHelperKernelWebservice!"

        // Act.
        let actual = try await service.getWelcomeMessage()

        // Assert.
        #expect(expected == actual)
    }

    @Test("Get health live should return ok")
    func getHealthLiveShouldReturnOK() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let expected = true

        // Act.
        let actual = try await service.getHealthLive()

        // Assert.
        #expect(actual == expected)
    }

    @Test("Get health ready should return ok")
    func getHealthReadyShouldReturnOK() async throws {

        // Arrange.
        let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
        let expected = true

        // Act.
        let actual = try await service.getHealthReady()

        // Assert.
        #expect(expected == actual)
    }
}
// swiftlint:enable type_body_length
