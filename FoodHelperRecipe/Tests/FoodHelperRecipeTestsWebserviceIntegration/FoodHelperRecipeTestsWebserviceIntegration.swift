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
import FoodHelperKernelImpl
import FoodHelperKernelDataAccessInMemory
import FoodHelperRecipe
import FoodHelperRecipeImpl

@testable import FoodHelperRecipeWebservice

@Suite("Webservice route Integration Tests", .serialized)

actor FoodHelperRecipeFaultyImpl: FoodHelperRecipe {

    func getAll() async throws(FoodHelperRecipeError) -> [Recipe] {
        throw FoodHelperRecipeError.cantAccessData
    }

    func getById(id: UUID) async throws(FoodHelperRecipeError) -> Recipe? {
        throw FoodHelperRecipeError.cantAccessData
    }

    func add(recipe: Recipe) async throws(FoodHelperRecipeError) {
        throw FoodHelperRecipeError.cantAccessData
    }

    func deleteById(id: UUID) async throws(FoodHelperRecipeError) {
        throw FoodHelperRecipeError.cantAccessData
    }
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable type_name
struct FoodHelperRecipeTestsWebserviceIntegration {
// swiftlint:enable type_name

    private func customWithApp(environment: Environment, _ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(environment)
        do {
            try await FoodHelperRecipeWebserviceFactory.configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    private func customWithAppWithFaultyService(
        environment: Environment, _ test: (Application) async throws -> Void) async throws {

            let app = try await Application.make(environment)
            do {
                let service = FoodHelperRecipeFaultyImpl()
                try await FoodHelperRecipeWebserviceFactory.configure(app, service)
                try await test(app)
            } catch {
                try await app.asyncShutdown()
                throw error
            }
            try await app.asyncShutdown()
    }

    @Test("customWithApp should cleanup and rethrow on error")
    func customWithAppShouldCleanupAndRethrowOnError() async throws {

        do {

            // Arrange.
            try await customWithApp(environment: .testing) { _ in

                // Act.
                throw CancellationError()
            }
        } catch {

            // Assert.
            #expect(true)
        }
    }

    @Test("customWithAppWithFaultyService should cleanup and rethrow on error")
    func customWithAppWithFaultyServiceShouldCleanupAndRethrowOnError() async throws {

        do {

            // Arrange.
            try await customWithAppWithFaultyService(environment: .testing) { _ in

                // Act.
                throw CancellationError()
            }
        } catch {

            // Assert.
            #expect(true)
        }
    }

    @Test("customWithApp with APP_PORT env should not explode",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func customWithAppWithAppPortEnvShouldNotExplode(environment: Environment) async throws {

        // Arrange.
        setenv("APP_PORT", "8082", 1)
        defer { unsetenv("APP_PORT") }

        // Act.
        try await customWithApp(environment: environment) { _ in

            // Assert.
            #expect(true)
        }
    }

    @Test("customWithApp should not explode",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func customWithAppShouldNotExplode(environment: Environment) async throws {

        // Arrange and act.
        try await customWithApp(environment: environment) { _ in

            // Assert.
            #expect(true)
        }
    }

    @Test("Get on /health/live should return 200",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnHealthLivePathShouldReturnsOK(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .ok

            // Act.
            try await app.testing().test(
                .GET,
                "/health/live",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }

    @Test("Get on /health/ready should return 200",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnHealthReadyPathShouldReturnsOK(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .ok

            // Act.
            try await app.testing().test(
                .GET,
                "/health/ready",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }

    @Test("Get on /health/ready on faulty app should return 503",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnHealthReadyOnPathOnFaulyAppShouldReturns503(environment: Environment) async throws {

        try await customWithAppWithFaultyService(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .serviceUnavailable

            // Act.
            try await app.testing().test(
                .GET,
                "/health/ready",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }

    @Test("Get on root path should return this welcome message")
    func getOnRootPathShouldReturnsWelcomeMessage() async throws {

        try await withApp(configure: { app in try await FoodHelperRecipeWebserviceFactory.configure(app) }, { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .ok
            let expectedResponse = "Welcome to FoodHelperRecipeWebservice!"

            // Act.
            try await app.testing().test(
                .GET,
                "/",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        })
    }

    @Test("Get on path /recipe should return all recipes",
          arguments: [Environment.development, Environment.testing, Environment.production])
// swiftlint:disable function_body_length
    func getOnPathKernelRecipeShouldReturnAllRecipes(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .ok
            let expectedResponse = #"""
            [
              {
                "id" : "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                "name" : "Tartine façon Zoé (Thème Naruto)",
                "steps" : [
                  {
                    "foods" : [
                      {
                        "name" : "Oignons",
                        "quantity" : 100,
                        "unit" : "gram"
                      },
                      {
                        "name" : "Huile d'olive",
                        "quantity" : 20,
                        "unit" : "gram"
                      },
                      {
                        "name" : "Dès de tomates en conserve",
                        "quantity" : 250,
                        "unit" : "gram"
                      },
                      {
                        "name" : "Sucre",
                        "quantity" : 30,
                        "unit" : "gram"
                      },
                      {
                        "name" : "Sel",
                        "quantity" : 10,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Eplucher les oignons.",
                      "Emincer les oignons.",
                      "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                      "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                      "Baisser le feu, puis ajouter les dès de tomates.",
                      "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                      "Réserver la sauce dans un bol."
                    ],
                    "title" : "On prépare la sauce."
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Comté",
                        "quantity" : 200,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Raper le fromage",
                      "Réserver le fromage rapé dans un bol."
                    ],
                    "title" : "Ca va raper !"
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Jambon blanc",
                        "quantity" : 150,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Couper grossièrement le jambon blanc.",
                      "Réserver dans un bol."
                    ],
                    "title" : "On prépare le jambon."
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Olives noires",
                        "quantity" : 50,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Couper les olives en fines tranches",
                      "Réserver dans un bol."
                    ],
                    "title" : "Et les olives alors ?"
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Champignon de Paris",
                        "quantity" : 100,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                      "Les couper en tranches moyenne.",
                      "Réserver dans un bol."
                    ],
                    "title" : "Les (bons ?) champigons de Paris."
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Pain",
                        "quantity" : 250,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Trancher le pain en fine tranches.",
                      "Arrondir les angles pour en faire une forme en bandeau.",
                      "Recouvrir une plate de cuisson de papier sulfurisé.",
                      "Répartir les tranches de pains sur la plaque."
                    ],
                    "title" : "On découpe le pain."
                  },
                  {
                    "foods" : [
                      {
                        "name" : "Origan",
                        "quantity" : 10,
                        "unit" : "gram"
                      },
                      {
                        "name" : "Herbes de provence",
                        "quantity" : 10,
                        "unit" : "gram"
                      }
                    ],
                    "instructions" : [
                      "Etaler la sauce sur les tranches de pains.",
                      "Etaler le jambon blanc.",
                      "Etaler le fromage rapé.",
                      "Etaler les tranches de champignons.",
                      "Etaler les tranches d'olives.",
                      "Disposer les épices pour former le signe du village caché souhaité"
                    ],
                    "title" : "On assemble, c'est bientôt fini."
                  },
                  {
                    "foods" : [

                    ],
                    "instructions" : [
                      "Faire chauffer le four à chaleur tournante à 180°C.",
                      "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                      "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                      "Sortir du four et laisser légèrement refroidir avant de déguster."
                    ],
                    "title" : "Au four !"
                  }
                ]
              }
            ]
            """#

            // Act.
            try await app.testing().test(
                .GET,
                "/recipe",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }
// swiftlint:enable function_body_length

// swiftlint:disable function_body_length
    @Test("Get on path /recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D should return this recipe",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnPathKernelRecipeWithIdShouldReturnThisRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .ok
            let expectedResponse = #"""
            {
              "id" : "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
              "name" : "Tartine façon Zoé (Thème Naruto)",
              "steps" : [
                {
                  "foods" : [
                    {
                      "name" : "Oignons",
                      "quantity" : 100,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Huile d'olive",
                      "quantity" : 20,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Dès de tomates en conserve",
                      "quantity" : 250,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sucre",
                      "quantity" : 30,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sel",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Eplucher les oignons.",
                    "Emincer les oignons.",
                    "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                    "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                    "Baisser le feu, puis ajouter les dès de tomates.",
                    "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                    "Réserver la sauce dans un bol."
                  ],
                  "title" : "On prépare la sauce."
                },
                {
                  "foods" : [
                    {
                      "name" : "Comté",
                      "quantity" : 200,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Raper le fromage",
                    "Réserver le fromage rapé dans un bol."
                  ],
                  "title" : "Ca va raper !"
                },
                {
                  "foods" : [
                    {
                      "name" : "Jambon blanc",
                      "quantity" : 150,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper grossièrement le jambon blanc.",
                    "Réserver dans un bol."
                  ],
                  "title" : "On prépare le jambon."
                },
                {
                  "foods" : [
                    {
                      "name" : "Olives noires",
                      "quantity" : 50,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper les olives en fines tranches",
                    "Réserver dans un bol."
                  ],
                  "title" : "Et les olives alors ?"
                },
                {
                  "foods" : [
                    {
                      "name" : "Champignon de Paris",
                      "quantity" : 100,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                    "Les couper en tranches moyenne.",
                    "Réserver dans un bol."
                  ],
                  "title" : "Les (bons ?) champigons de Paris."
                },
                {
                  "foods" : [
                    {
                      "name" : "Pain",
                      "quantity" : 250,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Trancher le pain en fine tranches.",
                    "Arrondir les angles pour en faire une forme en bandeau.",
                    "Recouvrir une plate de cuisson de papier sulfurisé.",
                    "Répartir les tranches de pains sur la plaque."
                  ],
                  "title" : "On découpe le pain."
                },
                {
                  "foods" : [
                    {
                      "name" : "Origan",
                      "quantity" : 10,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Herbes de provence",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Etaler la sauce sur les tranches de pains.",
                    "Etaler le jambon blanc.",
                    "Etaler le fromage rapé.",
                    "Etaler les tranches de champignons.",
                    "Etaler les tranches d'olives.",
                    "Disposer les épices pour former le signe du village caché souhaité"
                  ],
                  "title" : "On assemble, c'est bientôt fini."
                },
                {
                  "foods" : [

                  ],
                  "instructions" : [
                    "Faire chauffer le four à chaleur tournante à 180°C.",
                    "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                    "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                    "Sortir du four et laisser légèrement refroidir avant de déguster."
                  ],
                  "title" : "Au four !"
                }
              ]
            }
            """#

            // Act.
            try await app.testing().test(
                .GET,
                "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }
// swiftlint:enable function_body_length

    @Test("Get on path /recipe/not-an-uuid should return 400 bad request",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnPathKernelRecipeWithUnInvalidUUIDShouldReturn400BadRequest(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .badRequest
            let expectedResponse = #"""
            {
              "error" : true,
              "reason" : "Bad Request"
            }
            """#

            // Act.
            try await app.testing().test(
                .GET,
                "/recipe/im-not-a-valid-uuid",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }

    @Test("Get on path /recipe/unknown-uuid should return 404 not found",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnPathKernelRecipeWithUnknownIdShouldReturn404NotFound(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .notFound
            let expectedResponse = #"""
            {
              "error" : true,
              "reason" : "Not Found"
            }
            """#

            // Act.
            try await app.testing().test(
                .GET,
                "/recipe/00000000-0000-0000-0000-000000000000",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }

    @Test("Get on path /recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D on faulty app should return internal error",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func getOnPathKernelRecipeWithIdOnFaultyAppShouldReturnInternalError(environment: Environment) async throws {

        try await customWithAppWithFaultyService(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .internalServerError

            // Act.
            try await app.testing().test(
                .GET,
                "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }

    // swiftlint:disable function_body_length
    @Test("Post on path /recipe should return 201",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func postOnPathKernelRecipeShouldReturn201(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedPostStatus: HTTPResponseStatus = .created
            let expectedPostResponse = ""
            let expectedPostResponseHeaderLocation = "/recipe/A68A66C6-670B-4D48-8B25-8F9A61FD8E9D"
            let json = #"""
            {
              "id" : "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
              "name" : "Tartine façon Zoé (Thème Narutooo)",
              "steps" : [
                {
                  "foods" : [
                    {
                      "name" : "Oignons",
                      "quantity" : 100,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Huile d'olive",
                      "quantity" : 20,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Dès de tomates en conserve",
                      "quantity" : 250,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sucre",
                      "quantity" : 30,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sel",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Eplucher les oignons.",
                    "Emincer les oignons.",
                    "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                    "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                    "Baisser le feu, puis ajouter les dès de tomates.",
                    "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                    "Réserver la sauce dans un bol."
                  ],
                  "title" : "On prépare la sauce."
                },
                {
                  "foods" : [
                    {
                      "name" : "Comté",
                      "quantity" : 200,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Raper le fromage",
                    "Réserver le fromage rapé dans un bol."
                  ],
                  "title" : "Ca va raper !"
                },
                {
                  "foods" : [
                    {
                      "name" : "Jambon blanc",
                      "quantity" : 150,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper grossièrement le jambon blanc.",
                    "Réserver dans un bol."
                  ],
                  "title" : "On prépare le jambon."
                },
                {
                  "foods" : [
                    {
                      "name" : "Olives noires",
                      "quantity" : 50,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper les olives en fines tranches",
                    "Réserver dans un bol."
                  ],
                  "title" : "Et les olives alors ?"
                },
                {
                  "foods" : [
                    {
                      "name" : "Champignon de Paris",
                      "quantity" : 100,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                    "Les couper en tranches moyenne.",
                    "Réserver dans un bol."
                  ],
                  "title" : "Les (bons ?) champigons de Paris."
                },
                {
                  "foods" : [
                    {
                      "name" : "Pain",
                      "quantity" : 250,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Trancher le pain en fine tranches.",
                    "Arrondir les angles pour en faire une forme en bandeau.",
                    "Recouvrir une plate de cuisson de papier sulfurisé.",
                    "Répartir les tranches de pains sur la plaque."
                  ],
                  "title" : "On découpe le pain."
                },
                {
                  "foods" : [
                    {
                      "name" : "Origan",
                      "quantity" : 10,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Herbes de provence",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Etaler la sauce sur les tranches de pains.",
                    "Etaler le jambon blanc.",
                    "Etaler le fromage rapé.",
                    "Etaler les tranches de champignons.",
                    "Etaler les tranches d'olives.",
                    "Disposer les épices pour former le signe du village caché souhaité"
                  ],
                  "title" : "On assemble, c'est bientôt fini."
                },
                {
                  "foods" : [

                  ],
                  "instructions" : [
                    "Faire chauffer le four à chaleur tournante à 180°C.",
                    "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                    "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                    "Sortir du four et laisser légèrement refroidir avant de déguster."
                  ],
                  "title" : "Au four !"
                }
              ]
            }
            """#
            let jsonData = Data(json.utf8)

            // Act.
            try await app.testing().test(
                .POST,
                "/recipe",
                headers: ["Content-Type": "application/json"],
                body: .init(data: jsonData),
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string
                    let actualResponseHeaderLocation = response.headers["Location"].first

                    // Assert.
                    #expect(expectedPostStatus == actualStatus)
                    #expect(expectedPostResponse == actualResponse)
                    #expect(expectedPostResponseHeaderLocation == actualResponseHeaderLocation)
                }
            )

            let expectedGetStatus: HTTPResponseStatus = .ok
            let expectedGetResponse = #"""
            {
              "id" : "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
              "name" : "Tartine façon Zoé (Thème Narutooo)",
              "steps" : [
                {
                  "foods" : [
                    {
                      "name" : "Oignons",
                      "quantity" : 100,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Huile d'olive",
                      "quantity" : 20,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Dès de tomates en conserve",
                      "quantity" : 250,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sucre",
                      "quantity" : 30,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sel",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Eplucher les oignons.",
                    "Emincer les oignons.",
                    "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                    "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                    "Baisser le feu, puis ajouter les dès de tomates.",
                    "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                    "Réserver la sauce dans un bol."
                  ],
                  "title" : "On prépare la sauce."
                },
                {
                  "foods" : [
                    {
                      "name" : "Comté",
                      "quantity" : 200,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Raper le fromage",
                    "Réserver le fromage rapé dans un bol."
                  ],
                  "title" : "Ca va raper !"
                },
                {
                  "foods" : [
                    {
                      "name" : "Jambon blanc",
                      "quantity" : 150,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper grossièrement le jambon blanc.",
                    "Réserver dans un bol."
                  ],
                  "title" : "On prépare le jambon."
                },
                {
                  "foods" : [
                    {
                      "name" : "Olives noires",
                      "quantity" : 50,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper les olives en fines tranches",
                    "Réserver dans un bol."
                  ],
                  "title" : "Et les olives alors ?"
                },
                {
                  "foods" : [
                    {
                      "name" : "Champignon de Paris",
                      "quantity" : 100,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                    "Les couper en tranches moyenne.",
                    "Réserver dans un bol."
                  ],
                  "title" : "Les (bons ?) champigons de Paris."
                },
                {
                  "foods" : [
                    {
                      "name" : "Pain",
                      "quantity" : 250,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Trancher le pain en fine tranches.",
                    "Arrondir les angles pour en faire une forme en bandeau.",
                    "Recouvrir une plate de cuisson de papier sulfurisé.",
                    "Répartir les tranches de pains sur la plaque."
                  ],
                  "title" : "On découpe le pain."
                },
                {
                  "foods" : [
                    {
                      "name" : "Origan",
                      "quantity" : 10,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Herbes de provence",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Etaler la sauce sur les tranches de pains.",
                    "Etaler le jambon blanc.",
                    "Etaler le fromage rapé.",
                    "Etaler les tranches de champignons.",
                    "Etaler les tranches d'olives.",
                    "Disposer les épices pour former le signe du village caché souhaité"
                  ],
                  "title" : "On assemble, c'est bientôt fini."
                },
                {
                  "foods" : [

                  ],
                  "instructions" : [
                    "Faire chauffer le four à chaleur tournante à 180°C.",
                    "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                    "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                    "Sortir du four et laisser légèrement refroidir avant de déguster."
                  ],
                  "title" : "Au four !"
                }
              ]
            }
            """#
            try await app.testing().test(
                .GET,
                "/recipe/A68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedGetStatus == actualStatus)
                    #expect(expectedGetResponse == actualResponse)
                }
            )
        }
    }
    // swiftlint:enable function_body_length

    @Test("Post on path /recipe with invalid json should return 400",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func postOnPathKernelRecipeWithInvalidJSONShouldReturn400(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .badRequest
            let expectedResponse = #"""
            {
              "error" : true,
              "reason" : "Bad Request"
            }
            """#
            let json = #"{"id":"A68A66C6-670B-4D48-8B25-8F9A61FD8E9D","nameee":"Pizza with ananas"}"#
            let jsonData = Data(json.utf8)

            // Act.
            try await app.testing().test(
                .POST,
                "/recipe",
                headers: ["Content-Type": "application/json"],
                body: .init(data: jsonData),
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }

    // swiftlint:disable function_body_length
    @Test("Post on path /recipe on faulty app should return internal error",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func postOnPathKernelRecipeWithInvalidJSONShouldReturnInternalError(environment: Environment) async throws {

        try await customWithAppWithFaultyService(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .internalServerError
            let json = #"""
            {
              "id" : "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
              "name" : "Tartine façon Zoé (Thème Narutooo)",
              "steps" : [
                {
                  "foods" : [
                    {
                      "name" : "Oignons",
                      "quantity" : 100,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Huile d'olive",
                      "quantity" : 20,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Dès de tomates en conserve",
                      "quantity" : 250,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sucre",
                      "quantity" : 30,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Sel",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Eplucher les oignons.",
                    "Emincer les oignons.",
                    "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                    "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                    "Baisser le feu, puis ajouter les dès de tomates.",
                    "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                    "Réserver la sauce dans un bol."
                  ],
                  "title" : "On prépare la sauce."
                },
                {
                  "foods" : [
                    {
                      "name" : "Comté",
                      "quantity" : 200,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Raper le fromage",
                    "Réserver le fromage rapé dans un bol."
                  ],
                  "title" : "Ca va raper !"
                },
                {
                  "foods" : [
                    {
                      "name" : "Jambon blanc",
                      "quantity" : 150,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper grossièrement le jambon blanc.",
                    "Réserver dans un bol."
                  ],
                  "title" : "On prépare le jambon."
                },
                {
                  "foods" : [
                    {
                      "name" : "Olives noires",
                      "quantity" : 50,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Couper les olives en fines tranches",
                    "Réserver dans un bol."
                  ],
                  "title" : "Et les olives alors ?"
                },
                {
                  "foods" : [
                    {
                      "name" : "Champignon de Paris",
                      "quantity" : 100,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                    "Les couper en tranches moyenne.",
                    "Réserver dans un bol."
                  ],
                  "title" : "Les (bons ?) champigons de Paris."
                },
                {
                  "foods" : [
                    {
                      "name" : "Pain",
                      "quantity" : 250,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Trancher le pain en fine tranches.",
                    "Arrondir les angles pour en faire une forme en bandeau.",
                    "Recouvrir une plate de cuisson de papier sulfurisé.",
                    "Répartir les tranches de pains sur la plaque."
                  ],
                  "title" : "On découpe le pain."
                },
                {
                  "foods" : [
                    {
                      "name" : "Origan",
                      "quantity" : 10,
                      "unit" : "gram"
                    },
                    {
                      "name" : "Herbes de provence",
                      "quantity" : 10,
                      "unit" : "gram"
                    }
                  ],
                  "instructions" : [
                    "Etaler la sauce sur les tranches de pains.",
                    "Etaler le jambon blanc.",
                    "Etaler le fromage rapé.",
                    "Etaler les tranches de champignons.",
                    "Etaler les tranches d'olives.",
                    "Disposer les épices pour former le signe du village caché souhaité"
                  ],
                  "title" : "On assemble, c'est bientôt fini."
                },
                {
                  "foods" : [

                  ],
                  "instructions" : [
                    "Faire chauffer le four à chaleur tournante à 180°C.",
                    "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                    "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                    "Sortir du four et laisser légèrement refroidir avant de déguster."
                  ],
                  "title" : "Au four !"
                }
              ]
            }
            """#
            let jsonData = Data(json.utf8)

            // Act.
            try await app.testing().test(
                .POST,
                "/recipe",
                headers: ["Content-Type": "application/json"],
                body: .init(data: jsonData),
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
        @Test("Post on path /recipe with an existing recipe should return 201",
              arguments: [Environment.development, Environment.testing, Environment.production])
        func postOnPathKernelRecipeWithExistingRecipeShouldReturn201(environment: Environment) async throws {

            try await customWithApp(environment: environment) { app in

                // Arrange.
                let expectedPostStatus: HTTPResponseStatus = .created
                let expectedPostResponse = ""
                let expectedPostResponseHeaderLocation = "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D"
                let json = #"""
                {
                  "id" : "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                  "name" : "Tartine façon Zoé (Thème Narutooo)",
                  "steps" : [
                    {
                      "foods" : [
                        {
                          "name" : "Oignons",
                          "quantity" : 100,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Huile d'olive",
                          "quantity" : 20,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Dès de tomates en conserve",
                          "quantity" : 250,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Sucre",
                          "quantity" : 30,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Sel",
                          "quantity" : 10,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Eplucher les oignons.",
                        "Emincer les oignons.",
                        "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                        "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                        "Baisser le feu, puis ajouter les dès de tomates.",
                        "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                        "Réserver la sauce dans un bol."
                      ],
                      "title" : "On prépare la sauce."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Comté",
                          "quantity" : 200,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Raper le fromage",
                        "Réserver le fromage rapé dans un bol."
                      ],
                      "title" : "Ca va raper !"
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Jambon blanc",
                          "quantity" : 150,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Couper grossièrement le jambon blanc.",
                        "Réserver dans un bol."
                      ],
                      "title" : "On prépare le jambon."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Olives noires",
                          "quantity" : 50,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Couper les olives en fines tranches",
                        "Réserver dans un bol."
                      ],
                      "title" : "Et les olives alors ?"
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Champignon de Paris",
                          "quantity" : 100,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                        "Les couper en tranches moyenne.",
                        "Réserver dans un bol."
                      ],
                      "title" : "Les (bons ?) champigons de Paris."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Pain",
                          "quantity" : 250,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Trancher le pain en fine tranches.",
                        "Arrondir les angles pour en faire une forme en bandeau.",
                        "Recouvrir une plate de cuisson de papier sulfurisé.",
                        "Répartir les tranches de pains sur la plaque."
                      ],
                      "title" : "On découpe le pain."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Origan",
                          "quantity" : 10,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Herbes de provence",
                          "quantity" : 10,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Etaler la sauce sur les tranches de pains.",
                        "Etaler le jambon blanc.",
                        "Etaler le fromage rapé.",
                        "Etaler les tranches de champignons.",
                        "Etaler les tranches d'olives.",
                        "Disposer les épices pour former le signe du village caché souhaité"
                      ],
                      "title" : "On assemble, c'est bientôt fini."
                    },
                    {
                      "foods" : [

                      ],
                      "instructions" : [
                        "Faire chauffer le four à chaleur tournante à 180°C.",
                        "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                        "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                        "Sortir du four et laisser légèrement refroidir avant de déguster."
                      ],
                      "title" : "Au four !"
                    }
                  ]
                }
                """#
                let jsonData = Data(json.utf8)

                // Act.
                try await app.testing().test(
                    .POST,
                    "/recipe",
                    headers: ["Content-Type": "application/json"],
                    body: .init(data: jsonData),
                    afterResponse: { response async throws in

                        let actualStatus = response.status
                        let actualResponse = response.body.string
                        let actualResponseHeaderLocation = response.headers["Location"].first

                        // Assert.
                        #expect(expectedPostStatus == actualStatus)
                        #expect(expectedPostResponse == actualResponse)
                        #expect(expectedPostResponseHeaderLocation == actualResponseHeaderLocation)
                    }
                )

                let expectedGetStatus: HTTPResponseStatus = .ok
                let expectedGetResponse = #"""
                {
                  "id" : "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                  "name" : "Tartine façon Zoé (Thème Narutooo)",
                  "steps" : [
                    {
                      "foods" : [
                        {
                          "name" : "Oignons",
                          "quantity" : 100,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Huile d'olive",
                          "quantity" : 20,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Dès de tomates en conserve",
                          "quantity" : 250,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Sucre",
                          "quantity" : 30,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Sel",
                          "quantity" : 10,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Eplucher les oignons.",
                        "Emincer les oignons.",
                        "Verser l'huile d'olive dans une poële et faire chauffer à feu vif.",
                        "Ajouter les oignons et faire cuire jusqu'à ce qu'ils soit translucide. Remuser souvent.",
                        "Baisser le feu, puis ajouter les dès de tomates.",
                        "Ajouter le sucre (pour casser l'acidité de la tomate) et le sel. Laisser cuire 5 minutes.",
                        "Réserver la sauce dans un bol."
                      ],
                      "title" : "On prépare la sauce."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Comté",
                          "quantity" : 200,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Raper le fromage",
                        "Réserver le fromage rapé dans un bol."
                      ],
                      "title" : "Ca va raper !"
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Jambon blanc",
                          "quantity" : 150,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Couper grossièrement le jambon blanc.",
                        "Réserver dans un bol."
                      ],
                      "title" : "On prépare le jambon."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Olives noires",
                          "quantity" : 50,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Couper les olives en fines tranches",
                        "Réserver dans un bol."
                      ],
                      "title" : "Et les olives alors ?"
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Champignon de Paris",
                          "quantity" : 100,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Nettoyer les champignons de Paris (à l'eau, puis les essyuer avec un essuie-tout)",
                        "Les couper en tranches moyenne.",
                        "Réserver dans un bol."
                      ],
                      "title" : "Les (bons ?) champigons de Paris."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Pain",
                          "quantity" : 250,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Trancher le pain en fine tranches.",
                        "Arrondir les angles pour en faire une forme en bandeau.",
                        "Recouvrir une plate de cuisson de papier sulfurisé.",
                        "Répartir les tranches de pains sur la plaque."
                      ],
                      "title" : "On découpe le pain."
                    },
                    {
                      "foods" : [
                        {
                          "name" : "Origan",
                          "quantity" : 10,
                          "unit" : "gram"
                        },
                        {
                          "name" : "Herbes de provence",
                          "quantity" : 10,
                          "unit" : "gram"
                        }
                      ],
                      "instructions" : [
                        "Etaler la sauce sur les tranches de pains.",
                        "Etaler le jambon blanc.",
                        "Etaler le fromage rapé.",
                        "Etaler les tranches de champignons.",
                        "Etaler les tranches d'olives.",
                        "Disposer les épices pour former le signe du village caché souhaité"
                      ],
                      "title" : "On assemble, c'est bientôt fini."
                    },
                    {
                      "foods" : [

                      ],
                      "instructions" : [
                        "Faire chauffer le four à chaleur tournante à 180°C.",
                        "Une fois le four à la température souhaitée, enfourner le plaque de cuisson.",
                        "Surveiller attentivement la cuisson pour l'arrêter au moment souhaité (grillé/fondue).",
                        "Sortir du four et laisser légèrement refroidir avant de déguster."
                      ],
                      "title" : "Au four !"
                    }
                  ]
                }
                """#
                try await app.testing().test(
                    .GET,
                    "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                    afterResponse: { response async throws in

                        let actualStatus = response.status
                        let actualResponse = response.body.string

                        // Assert.
                        #expect(expectedGetStatus == actualStatus)
                        #expect(expectedGetResponse == actualResponse)
                    }
                )
            }
        }
    // swiftlint:enable function_body_length

        @Test("Post on path /recipe with a new small recipe should return 201",
              arguments: [Environment.development, Environment.testing, Environment.production])
        func postOnPathKernelRecipeWithNewSimpleRecipeShouldReturn201(environment: Environment) async throws {

            try await customWithApp(environment: environment) { app in

                // Arrange.
                let expectedPostStatus: HTTPResponseStatus = .created
                let expectedPostResponse = ""
                let expectedPostResponseHeaderLocation = "/recipe/00000000-0000-0000-0000-000000000000"
                let json = #"""
                {
                  "id" : "00000000-0000-0000-0000-000000000000",
                  "name" : "Pizza",
                  "steps" : []
                }
                """#
                let jsonData = Data(json.utf8)

                // Act.
                try await app.testing().test(
                    .POST,
                    "/recipe",
                    headers: ["Content-Type": "application/json"],
                    body: .init(data: jsonData),
                    afterResponse: { response async throws in

                        let actualStatus = response.status
                        let actualResponse = response.body.string
                        let actualResponseHeaderLocation = response.headers["Location"].first

                        // Assert.
                        #expect(expectedPostStatus == actualStatus)
                        #expect(expectedPostResponse == actualResponse)
                        #expect(expectedPostResponseHeaderLocation == actualResponseHeaderLocation)
                    }
                )

                let expectedGetStatus: HTTPResponseStatus = .ok
                let expectedGetResponse = #"""
                {
                  "id" : "00000000-0000-0000-0000-000000000000",
                  "name" : "Pizza",
                  "steps" : [

                  ]
                }
                """#
                try await app.testing().test(
                    .GET,
                    "/recipe/00000000-0000-0000-0000-000000000000",
                    afterResponse: { response async throws in

                        let actualStatus = response.status
                        let actualResponse = response.body.string

                        // Assert.
                        #expect(expectedGetStatus == actualStatus)
                        #expect(expectedGetResponse == actualResponse)
                    }
                )
            }
        }

    @Test("Delete on path /recipe/{uuid} should return 204 and remove recipe",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func deleteOnPathKernelRecipeShouldReturn200AndRemoveRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedDeleteStatus: HTTPResponseStatus = .noContent
            let expectedGetStatus: HTTPResponseStatus = .notFound

            // Act.
            try await app.testing().test(
                .DELETE,
                "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedDeleteStatus == actualStatus)
                }
            )

            try await app.testing().test(
                .GET,
                "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedGetStatus == actualStatus)
                }
            )
        }
    }

    @Test("Delete on path /recipe/{uuid} on faulty app should return internal server error",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func deleteOnPathKernelRecipeOnFaultyAppShouldReturnCantAccessData(environment: Environment) async throws {

        try await customWithAppWithFaultyService(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .internalServerError

            // Act.
            try await app.testing().test(
                .DELETE,
                "/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }

    @Test("Delete on path /recipe/not-an-uuid should return 400 bad request",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func deleteOnPathKernelRecipeWithUnInvalidUUIDShouldReturn400BadRequest(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .badRequest
            let expectedResponse = #"""
            {
              "error" : true,
              "reason" : "Bad Request"
            }
            """#

            // Act.
            try await app.testing().test(
                .DELETE,
                "/recipe/im-not-a-valid-uuid",
                afterResponse: { response async throws in

                    let actualStatus = response.status
                    let actualResponse = response.body.string

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                    #expect(expectedResponse == actualResponse)
                }
            )
        }
    }

    @Test("Delete on path /recipe/unknown-uuid should return 204",
          arguments: [Environment.development, Environment.testing, Environment.production])
    func deleteOnPathKernelRecipeWithUnknownIdShouldReturn404(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let expectedStatus: HTTPResponseStatus = .noContent

            // Act.
            try await app.testing().test(
                .DELETE,
                "/recipe/00000000-0000-0000-0000-000000000000",
                afterResponse: { response async throws in

                    let actualStatus = response.status

                    // Assert.
                    #expect(expectedStatus == actualStatus)
                }
            )
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
