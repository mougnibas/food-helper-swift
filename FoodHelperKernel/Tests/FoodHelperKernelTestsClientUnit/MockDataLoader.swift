// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

import FoodHelperKernel
import FoodHelperKernelClient

// swiftlint:disable file_length
// swiftlint:disable type_body_length
actor MockDataLoader: DataLoading {

    /// Responses for GET verb.
    private var getResponses: [String: (data: Data, statusCode: Int)] = [:]

    /// Responses for POST verb.
    private var postResponses: [String: (data: Data, statusCode: Int)] = [:]

    /// Responses for DELETE verb.
    private var deleteResponses: [String: (data: Data, statusCode: Int)] = [:]

    init() {

        // Get for welcome message.
        let welcomeMessage: (String, Int) = Self.getWelcomeMessage()
        getResponses["http://localhost:8080/"] =
            (welcomeMessage.0.data(using: .utf8)!, welcomeMessage.1)

        // Get for health live.
        getResponses["http://localhost:8080/health/live"] = (Data(), 200)

        // Get for health ready.
        getResponses["http://localhost:8080/health/ready"] = (Data(), 200)

        // Get for all recipe.
        let allRecipes: (String, Int) = Self.getAllRecipes()
        getResponses["http://localhost:8080/kernel/recipe"] =
            (allRecipes.0.data(using: .utf8)!, allRecipes.1)

        // Get for recipe 000.
        let recipe000: (String, Int) = Self.getRecipe000()
        getResponses["http://localhost:8080/kernel/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D"] =
            (recipe000.0.data(using: .utf8)!, recipe000.1)

        // Get for recipe 001.
        let recipe001: (String, Int) = Self.getRecipe001()
        getResponses["http://localhost:8080/kernel/recipe/A68A66C6-670B-4D48-8B25-8F9A61FD8E9D"] =
            (recipe001.0.data(using: .utf8)!, recipe001.1)

        // Get for 404 on this given recipe.
        let myRecipe404: (String, Int) = Self.getMyRecipe404()
        getResponses["http://localhost:8080/kernel/recipe/40000000-0000-0000-0000-000000000004"] =
            (myRecipe404.0.data(using: .utf8)!, myRecipe404.1)

        // Get for 500 on this given recipe.
        let myRecipe500: (String, Int) = Self.getMyRecipe500()
        getResponses["http://localhost:8080/kernel/recipe/50000000-0000-0000-0000-000000000000"] =
            (myRecipe500.0.data(using: .utf8)!, myRecipe500.1)

        // Post for 201
        postResponses["http://localhost:8080/kernel/recipe"] = (Data(), 201)

        // Delete for 204.
        deleteResponses["http://localhost:8080/kernel/recipe/A68A66C6-670B-4D48-8B25-8F9A61FD8E9D"] = (Data(), 204)

        // Delete for 404.
        deleteResponses["http://localhost:8080/kernel/recipe/00000000-0000-0000-0000-000000000000"] = (Data(), 404)
    }

    // swiftlint:disable function_body_length
    private static func getAllRecipes() -> (String, Int) {

        let content = #"""
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
        let statut = 200
        return (content, statut)
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    private static func getRecipe000() -> (String, Int) {

        let content = #"""
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
        let statut = 200
        return (content, statut)
    }
    // swiftlint:enable function_body_length

    private static func getRecipe001() -> (String, Int) {

        let content = #"""
        {
          "id" : "A68A66C6-670B-4D48-8B25-8F9A61FD8E9D",
          "name" : "Raclette",
          "steps" : []
        }
        """#
        let statut = 200
        return (content, statut)
    }

    private static func getWelcomeMessage() -> (String, Int) {
        let content = "Welcome to FoodHelperKernelWebservice!"
        let statut = 200
        return (content, statut)
    }

    private static func getMyRecipe404() -> (String, Int) {

        let content = #"""
        {
          "error" : true,
          "reason" : "Not Found"
        }
        """#
        let statut = 404
        return (content, statut)
    }

    private static func getMyRecipe500() -> (String, Int) {

        let content = #"""
        {
          "error" : true,
          "reason" : "internal error"
        }
        """#
        let statut = 500
        return (content, statut)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {

        switch request.httpMethod {
        case "POST":
            return responseForPost(request)
        case "DELETE":
            return responseForDelete(request)
        case "GET", _:
            return responseForGet(request)
        }
    }

    private func responseForGet(_ request: URLRequest) -> (Data, URLResponse) {
        let url = request.url!.absoluteString
        let result = getResponses[url]!

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: result.statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"])!

        return (result.data, response)
    }

    private func responseForPost(_ request: URLRequest) -> (Data, URLResponse) {
        let url = request.url!.absoluteString
        let result = postResponses[url]!

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: result.statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"])!

        return (result.data, response)
    }

    private func responseForDelete(_ request: URLRequest) -> (Data, URLResponse) {
        let url = request.url!.absoluteString
        let result = deleteResponses[url]!

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: result.statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"])!

        return (result.data, response)
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
