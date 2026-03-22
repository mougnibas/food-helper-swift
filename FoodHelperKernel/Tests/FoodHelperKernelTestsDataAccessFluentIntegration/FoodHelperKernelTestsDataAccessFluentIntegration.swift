// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

import Vapor
import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver

import FoodHelperKernel
import FoodHelperKernelDataAccess
@testable import FoodHelperKernelDataAccessFluent

@Suite("FoodHelperKernelDataAccessFluent Integration Tests", .serialized)
// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable type_name
struct FoodHelperKernelTestsDataAccessFluentIntegration {
// swiftlint:enable type_name

    private func customWithApp(environment: Environment, _ test: (Application) async throws -> Void) async throws {

        let app = try await Application.make(environment)
        do {

            // SQLite / MySQL switch.
            // Can't use FoodHelperKernelWebserviceFactory to avoid cyclic dependencies.
            switch environment {
            case .testing:
                app.databases.use(.sqlite(.memory), as: .sqlite)
            case .production, _:
                let dbHostname = "0.0.0.0"
                let dbUsername = "kernel-db-user"
                let dbPassword = "kernel-db-password"
                let dbDatabase = "kernel-db"
                var tls = TLSConfiguration.makeClientConfiguration()
                tls.certificateVerification = .none
                app.databases.use(.mysql(
                    hostname: dbHostname,
                    username: dbUsername,
                    password: dbPassword,
                    database: dbDatabase,
                    tlsConfiguration: tls
                ), as: .mysql)
            }

            app.migrations.add(Migration000())
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("customWithApp should cleanup and rethrow on error")
    func customWithAppShouldCleanupAndRethrowOnError() async throws {

        await #expect(throws: CancellationError.self) {
            try await customWithApp(environment: .testing) { _ in
                throw CancellationError()
            }
        }
    }

    // swiftlint:disable function_body_length
    private func makeRecipe() -> Recipe {

        Recipe(
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
    }
    // swiftlint:enable function_body_length

    @Test("New service should not explode",
          arguments: [Environment.testing, Environment.production])
    func newServiceShouldNotExplode(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange and act.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())

            // Assert.
            #expect(true)
        }
    }

    @Test("Get identifiers should return these uuids",
          arguments: [Environment.testing, Environment.production])
    func getIdentifiersShouldReturnTheseUuids(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
            let expected = [UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!]

            // Act.
            let actual = try await service.getIdentifiers()

            // Assert.
            #expect(expected == actual)
        }
    }

    // swiftlint:disable function_body_length
    @Test("Get by identifier should return this recipe",
          arguments: [Environment.testing, Environment.production])
    func getByIdentifierShouldReturnThisRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
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
            let actual = try await service.getByIdentifier(UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!)

            // Assert.
            #expect(expected == actual)
        }
    }
    // swiftlint:enable function_body_length

    @Test("Get by identifier with unknown ID, should return nil",
          arguments: [Environment.testing, Environment.production])
    func getByIdentifierWithUnknowIdShouldReturnNil(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
            let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

            // Act.
            let actual = try? await service.getByIdentifier(unknownId)

            // Assert.
            #expect(actual == nil)
        }
    }

    @Test("Delete by identifier should remove recipe",
          arguments: [Environment.testing, Environment.production])
    func deleteByIdentifierShouldRemoveRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
            let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!

            // Act.
            try await service.deleteByIdentifier(id)
            let actual = try? await service.getByIdentifier(id)

            // Assert.
            #expect(actual == nil)
        }
    }

    @Test("Delete by identifier with unknown ID should not throw",
          arguments: [Environment.testing, Environment.production])
    func deleteByIdentifierWithUnknownIdShouldNotThrow(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
            let unknownId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

            // Act.
            try await service.deleteByIdentifier(unknownId)

            // Assert.
            #expect(true)
        }
    }

    // swiftlint:disable function_body_length
    @Test("createOrUpdate with existing recipe, should return updated recipe",
          arguments: [Environment.testing, Environment.production])
    func createOrUpdateCallWithExistingRecipeShouldReturnUpdatedRecipe(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await service.createOrUpdate(makeRecipe())
            let expected = Recipe(
                id: UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!,
                name: "Tartine façon Zoé (Thème Narutooo)",
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
            try await service.createOrUpdate(expected)
            let actual = try? await service.getByIdentifier(expected.id)

            // Assert.
            #expect(expected == actual)
        }
        // swiftlint:enable function_body_length
    }

    @Test("Get identifiers should throw cantAccessData when tables are missing",
          arguments: [Environment.testing, Environment.production])
    func getIdentifiersShouldThrowCantAccessDataWhenTablesAreMissing(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            try await app.autoRevert()

            // Act and assert.
            await #expect(throws: FoodHelperKernelDataAccessError.cantAccessData) {
                _ = try await service.getIdentifiers()
            }
        }
    }

    @Test("Get by identifier should throw cantAccessData when tables are missing",
          arguments: [Environment.testing, Environment.production])
    func getByIdentifierShouldThrowCantAccessWhenTablesAreMissing(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
            try await app.autoRevert()

            // Act and assert.
            await #expect(throws: FoodHelperKernelDataAccessError.cantAccessData) {
                _ = try await service.getByIdentifier(id)
            }
        }
    }

    @Test("Create or update should throw cantAccessData when tables are missing",
          arguments: [Environment.testing, Environment.production])
    func createOrUpdateShouldThrowCantAccessWhenTablesAreMissing(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            let recipe = makeRecipe()
            try await app.autoRevert()

            // Act and assert.
            await #expect(throws: FoodHelperKernelDataAccessError.cantAccessData) {
                try await service.createOrUpdate(recipe)
            }
        }
    }

    @Test("Delete by identifier should throw cantAccessData when tables are missing",
          arguments: [Environment.testing, Environment.production])
    func deleteByIdentifierShouldThrowCantAccessWhenTablesAreMissing(environment: Environment) async throws {

        try await customWithApp(environment: environment) { app in

            // Arrange.
            let service = try await FoodHelperKernelDataAccessFluent(app.db)
            let id = UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!
            try await app.autoRevert()

            // Act and assert.
            await #expect(throws: FoodHelperKernelDataAccessError.cantAccessData) {
                try await service.deleteByIdentifier(id)
            }
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
