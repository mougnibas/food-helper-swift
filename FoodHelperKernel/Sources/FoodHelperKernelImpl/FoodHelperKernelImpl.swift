// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import FoodHelperKernel
import FoodHelperKernelDataAccess

/// A simple implementation of `FoodHelperService`.
public actor FoodHelperKernelImpl: FoodHelperKernel {

    /// Data access layer.
    private let dataAccess: FoodHelperKernelDataAccess

    /// Initialize the service.
    public init(dataAccess: FoodHelperKernelDataAccess) async throws(FoodHelperKernelError) {

        // Reference data access.
        self.dataAccess = dataAccess

        // Seed recipes.
        try await initialSeed(dataAccess: dataAccess)
    }

    private func initialSeed(dataAccess: FoodHelperKernelDataAccess) async throws(FoodHelperKernelError) {

        // Tartine façon Zoé.
        if try await getRecipeById(id: UUID(uuidString: "B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")!) == nil {
            let recipe000 = makeRecipe000()
            try await addRecipe(recipe: recipe000)
        }
    }

    // Swift ling rule disable because recipes are long to describe.
    // swiftlint:disable:next function_body_length
    private func makeRecipe000() -> Recipe {

        let recipe = Recipe(
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

        return recipe
    }

    /// Get all known recipes.
    public func getAllRecipes() async throws(FoodHelperKernelError) -> [Recipe] {

        do {
            // Fetch all identifiers first.
            let ids = try await dataAccess.getIdentifiers()

            // Fetch all recipes for those identifiers.
            var recipes: [Recipe] = []
            for id in ids {
                let recipe = try await dataAccess.getByIdentifier(id)
                if let unwrappedRecipe = recipe {
                    recipes.append(unwrappedRecipe)
                }
            }
            return recipes
        } catch {
            throw .cantAccessData
        }
    }

    /// Get a single recipe by its unique identifier.
    public func getRecipeById(id: UUID) async throws(FoodHelperKernelError) -> Recipe? {

        do {
            return try await dataAccess.getByIdentifier(id)
        } catch {
            throw .cantAccessData
        }
    }

    /// Add a new recipe.
    public func addRecipe(recipe: Recipe) async throws(FoodHelperKernelError) {

        do {
            try await dataAccess.createOrUpdate(recipe)
        } catch {
            throw .cantAccessData
        }
    }

    /// Delete a recipe by its unique identifier.
    public func deleteRecipeById(id: UUID) async throws(FoodHelperKernelError) {

        do {
            try await dataAccess.deleteByIdentifier(id)
        } catch {
            throw .cantAccessData
        }
    }
}
