// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

import Vapor
import VaporTesting

import FoodHelperKernel
import FoodHelperKernelDataAccess
import FoodHelperKernelDataAccessInMemory
import FoodHelperKernelClient
@testable import FoodHelperKernelWebservice

private actor PartiallyFailingDataAccess: FoodHelperKernelDataAccess {

    let dataAccess = FoodHelperKernelDataAccessInMemory()

    func getIdentifiers() async throws(FoodHelperKernelDataAccessError) -> [UUID] {
        throw .cantAccessData
    }

    func getByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) -> Recipe? {
        return try await dataAccess.getByIdentifier(id)
    }

    func createOrUpdate(_ recipe: Recipe) async throws(FoodHelperKernelDataAccessError) {
        try await dataAccess.createOrUpdate(recipe)
    }

    func deleteByIdentifier(_ id: UUID) async throws(FoodHelperKernelDataAccessError) {
        throw .cantAccessData
    }
}

@Suite("Client Integration Tests", .serialized)
// swiftlint:disable file_length
// swiftlint:disable type_body_length
final class FoodHelperKernelTestsClientIntegration {

    private static let localPort = 8081
    private static let localBaseUrl = URL(string: "http://127.0.0.1:\(localPort)")!

    private let port = FoodHelperKernelTestsClientIntegration.localPort
    private var baseUrl = FoodHelperKernelTestsClientIntegration.localBaseUrl

    private func customWithApp(environment: Environment, _ test: (Application) async throws -> Void) async throws {

        // We need to sanitized arguments because Xcode add arguments, but Vapor don't like them.
        let sanitizedArguments: [String] = Array(environment.arguments.prefix(1))

        // Add APP_PORT arg for Vapor.
        setenv("APP_PORT", "\(port)", 1)
        defer { unsetenv("APP_PORT") }

        // Usual startup instructions.
        let sanitizedEnvironment = Environment(name: environment.name, arguments: sanitizedArguments)
        let app = try await Application.make(sanitizedEnvironment)
        do {
            try await FoodHelperKernelWebserviceFactory.configure(app)
            try await app.startup()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    private func customWithAppWithDefaultPort(
        environment: Environment, _ test: (Application) async throws -> Void) async throws {

        // We need to sanitized arguments because Xcode add arguments, but Vapor don't like them.
        let sanitizedArguments: [String] = Array(environment.arguments.prefix(1))

        // Usual startup instructions.
        let sanitizedEnvironment = Environment(name: environment.name, arguments: sanitizedArguments)
        let app = try await Application.make(sanitizedEnvironment)
        do {
            try await FoodHelperKernelWebserviceFactory.configure(app)
            try await app.startup()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    private func customWithAppWithGivenConfig(
        environment: Environment, _ test: (Application) async throws -> Void) async throws {

        let data = PartiallyFailingDataAccess()

        // We need to sanitized arguments because Xcode add arguments, but Vapor don't like them.
        let sanitizedArguments: [String] = Array(environment.arguments.prefix(1))

        // Add APP_PORT arg for Vapor.
        setenv("APP_PORT", "\(port)", 1)
        defer { unsetenv("APP_PORT") }

        // Usual startup instructions.
        let sanitizedEnvironment = Environment(name: environment.name, arguments: sanitizedArguments)
        let app = try await Application.make(sanitizedEnvironment)
        do {
            try await FoodHelperKernelWebserviceFactory.configure(app, data)
            try await app.startup()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    private func customWithAppWithGivenConfigWithDefaultPort(
        environment: Environment, _ test: (Application) async throws -> Void) async throws {

        let data = PartiallyFailingDataAccess()

        // We need to sanitized arguments because Xcode add arguments, but Vapor don't like them.
        let sanitizedArguments: [String] = Array(environment.arguments.prefix(1))

        // Usual startup instructions.
        let sanitizedEnvironment = Environment(name: environment.name, arguments: sanitizedArguments)
        let app = try await Application.make(sanitizedEnvironment)
        do {
            try await FoodHelperKernelWebserviceFactory.configure(app, data)
            try await app.startup()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("PartiallyFailingDataAccess should throw cantAccessData on deleteByIdentifier")
    func partiallyFailingDataAccessShouldThrowCantAccessDataOnDeleteByIdentifier() async throws {

        // Arrange.
        let service = PartiallyFailingDataAccess()

        // Act and assert.
        await #expect(throws: FoodHelperKernelDataAccessError.cantAccessData) {
            _ = try await service.deleteByIdentifier(UUID.generateRandom())
        }
    }

    @Test("PartiallyFailingDataAccess should return nil on getByIdentifier with unknow identifier")
    func partiallyFailingDataAccessShouldReturnNilOnGetByIdentifierWithUnknownIdentifier() async throws {

        // Arrange.
        let service = PartiallyFailingDataAccess()
        let unknownUuid = UUID.init(uuidString: "00000000-0000-0000-0000-000000000404")!
        let expected: Recipe? = nil

        // Act.
        let actual = try await service.getByIdentifier(unknownUuid)

        // Assert.
        #expect(expected == actual)
    }

    @Test("PartiallyFailingDataAccess should not explode on createOrUpdate")
    func partiallyFailingDataAccessShouldNotExplodeOnCreateOrUpdate() async throws {

        // Arrange.
        let service = PartiallyFailingDataAccess()
        let newRecipe = Recipe(name: "new recipe")

        // Act.
        _ = try await service.createOrUpdate(newRecipe)

        // Assert.
        #expect(true)
    }

    @Test("customWithApp should cleanup and rethrow on error")
    func customWithAppShouldCleanupAndRethrowOnError() async throws {

        await #expect(throws: CancellationError.self) {
            try await customWithApp(environment: .testing) { _ in
                throw CancellationError()
            }
        }
    }

    @Test("customWithAppWithDefaultPort should cleanup and rethrow on error")
    func customWithAppWithDefaultPortShouldCleanupAndRethrowOnError() async throws {

        await #expect(throws: CancellationError.self) {
            try await customWithAppWithDefaultPort(environment: .testing) { _ in
                throw CancellationError()
            }
        }
    }

    @Test("customWithAppWithGivenConfig should cleanup and rethrow on error")
    func customWithAppWithGivenConfigShouldCleanupAndRethrowOnError() async throws {

        await #expect(throws: CancellationError.self) {
            try await customWithAppWithGivenConfig(environment: .testing) { _ in
                throw CancellationError()
            }
        }
    }

    @Test("customWithAppWithGivenConfigWithDefaultPort should cleanup and rethrow on error")
    func customWithAppWithGivenConfigWithDefaultPortShouldCleanupAndRethrowOnError() async throws {

        await #expect(throws: CancellationError.self) {
            try await customWithAppWithGivenConfigWithDefaultPort(environment: .testing) { _ in
                throw CancellationError()
            }
        }
    }

    @Test("Default constructor should not explode")
    func defaultConstructorShouldNotExplode() async throws {

        // Arrange and act.
        _ = FoodHelperKernelClient()

        // Assert.
        #expect(true)
    }

    @Test("Constructor with base URL should not explode")
    func constructorWithBaseUrlShouldNotExplode() async throws {

        // Arrange.
        let baseURL = URL(string: "http://localhost:8080")!

        // Act.
        _ = FoodHelperKernelClient(baseURL: baseURL)

        // Assert.
        #expect(true)
    }

    // swiftlint:disable function_body_length
    @Test("getAllRecipe should return this first recipes",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getAllRecipesShouldReturnAllRecipes(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

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
            let actual: Recipe = recipes[0]

            // Assert
            #expect(recipes.count == 1)
            #expect(expected == actual)
        }
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    @Test("Get recipe by this ID should return this recipe",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getRecipeByIdShouldReturnThisRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

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
    }
    // swiftlint:enable function_body_length

    @Test("Get recipe with unknown ID should return nil",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getRecipeWithUnknownIdShouldReturnNil(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

            // Act.
            let actual = try? await service.getRecipeById(id: unknownId)

            // Act.
            #expect(actual == nil)
        }
    }

    @Test("Add a new recipe then getting this new recipe should be the same",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func addANewRecipeAndGetItShouldBeTheSame(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
            let name = "Raclette"
            let expected = Recipe(id: id, name: name)

            // Act.
            _ = try await service.addRecipe(recipe: expected)
            let actual = try await service.getRecipeById(id: id)

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Delete recipe by id should remove the recipe",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func deleteRecipeByIdShouldRemoveRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

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
    }

    @Test("On full init, add a new recipe then getting this new recipe should be the same",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func onFullInitAddANewRecipeAndGetItShouldBeTheSame(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
            let name = "Raclette"
            let expected = Recipe(id: id, name: name)

            // Act.
            _ = try await service.addRecipe(recipe: expected)
            let actual = try await service.getRecipeById(id: id)

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("On full init with default port, add a new recipe then getting this new recipe should be the same",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func onFullInitWithDefaultPortAddANewRecipeAndGetItShouldBeTheSame(environment: Environment) async throws {

        try await customWithAppWithDefaultPort(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient()
            let id = UUID(uuidString: "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
            let name = "Raclette"
            let expected = Recipe(id: id, name: name)

            // Act.
            _ = try await service.addRecipe(recipe: expected)
            let actual = try await service.getRecipeById(id: id)

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Get welcome message should return expected string",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getWelcomeMessageShouldReturnExpectedString(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let expected = "Welcome to FoodHelperKernelWebservice!"

            // Act.
            let actual = try await service.getWelcomeMessage()

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Get health live should return ok",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getHealthLiveShouldReturnOK(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let expected = true

            // Act.
            let actual = try await service.getHealthLive()

            // Assert.
            #expect(actual == expected)
        }
    }

    @Test("Get health live with invalid URL should throw CantAccessData")
    func getHealthLiveWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                _ = try await service.getHealthLive()
            }
        }
    }

    @Test("Get all recipes with invalid URL should throw CantAccessData")
    func getAllRecipesWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                _ = try await service.getAllRecipes()
            }
        }
    }

    @Test("Get recipe by id with invalid URL should throw CantAccessData")
    func getRecipeByIdWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)
            let id = UUID()

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                _ = try await service.getRecipeById(id: id)
            }
        }
    }

    @Test("Add recipe with invalid URL should throw CantAccessData")
    func addRecipeWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)
            let recipe = Recipe(id: UUID(), name: "Raclette")

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                try await service.addRecipe(recipe: recipe)
            }
        }
    }

    @Test("Delete recipe by id with invalid URL should throw CantAccessData")
    func deleteRecipeByIdWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)
            let id = UUID()

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                try await service.deleteRecipeById(id: id)
            }
        }
    }

    @Test("Get welcome message with invalid URL should throw CantAccessData")
    func getWelcomeMessageWithInvalidUrlShouldThrowCantAccessData() async throws {

        try await customWithApp(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)

            // Act and assert.
            await #expect(throws: FoodHelperKernelError.cantAccessData) {
                _ = try await service.getWelcomeMessage()
            }
        }
    }

    @Test("Get health ready should return ok",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getHealthReadyShouldReturnOK(environment: Environment) async throws {

        try await customWithApp(environment: environment) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let expected = true

            // Act.
            let actual = try await service.getHealthReady()

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Get heath ready with invalid data source should return false")
    func getHealthReadyWithInvalidDataSourceShouldReturnFalse() async throws {

        try await customWithAppWithGivenConfig(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let expected = false

            // Act.
            let actual = try await service.getHealthReady()

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Get heath ready with invalid data source with default port should return false")
    func getHealthReadyWithInvalidDataSourceWithDefaultPortShouldReturnFalse() async throws {

        try await customWithAppWithGivenConfigWithDefaultPort(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: baseUrl, loader: URLSession.shared)
            let expected = false

            // Act.
            let actual = try await service.getHealthReady()

            // Assert.
            #expect(expected == actual)
        }
    }

    @Test("Get heath ready with invalid URL should return false")
    func getHealthReadyWithInvalidUrlShouldReturnFalse() async throws {

        try await customWithAppWithGivenConfig(environment: .testing) { _ in

            // Arrange.
            let service = FoodHelperKernelClient(baseURL: URL(string: "http://127.0.0.1:1")!, loader: URLSession.shared)
            let expected = false

            // Act.
            let actual = try await service.getHealthReady()

            // Assert.
            #expect(expected == actual)
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
