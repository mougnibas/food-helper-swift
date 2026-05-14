// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation
import Testing

// swiftlint:disable file_length
// swiftlint:disable type_body_length

@Suite("Webservice route end-to-end Tests", .serialized)
struct FoodHelperRecipeTestsWebserviceEndToEnd {

    @Test("Get on /health/live should return 200")
    func getOnHealthLivePathShouldReturnsOK() async throws {

        // Arrange.
        let expectedStatusCode = 200
        let url = URL(string: "http://localhost:8081/health/live")
        let request = URLRequest(url: url!)
        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
    }

    @Test("Get on /health/ready should return 200")
    func getOnHealthReadyPathShouldReturnsOK() async throws {

        // Arrange.
        let expectedStatusCode = 200
        let url = URL(string: "http://localhost:8081/health/ready")
        let request = URLRequest(url: url!)
        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
    }

    @Test("Get on root path should return this welcome message")
    func getOnRootPathShouldReturnsWelcomeMessage() async throws {

        // Arrange.
        let expectedStatusCode = 200
        let expectedResponse = "Welcome to FoodHelperRecipeWebservice!"
        let url = URL(string: "http://localhost:8081/")
        let request = URLRequest(url: url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }

    // swiftlint:disable function_body_length
    @Test("Get on path /recipe should return all recipes")
    func getOnPathRecipeShouldReturnAllRecipes() async throws {

        // Arrange.
        let expectedStatusCode = 200
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
        let url = URL(string: "http://localhost:8081/recipe")
        let request = URLRequest(url: url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }
    // swiftlint:enable function_body_length

    // swiftlint:disable function_body_length
    @Test("Get on path /recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D should return this recipe")
    func getOnPathRecipeWithIdShouldReturnThisRecipe() async throws {

        // Arrange.
        let expectedStatusCode = 200
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

        let url = URL(string: "http://localhost:8081/recipe/B68A66C6-670B-4D48-8B25-8F9A61FD8E9D")
        let request = URLRequest(url: url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }
    // swiftlint:enable function_body_length

    @Test("Get on path /recipe/not-an-uuid should return 400 bad request")
    func getOnPathRecipeWithUnInvalidUUIDShouldReturn400BadRequest() async throws {

        // Arrange.
        let expectedStatusCode = 400
        let expectedResponse = #"""
        {
          "error" : true,
          "reason" : "Bad Request"
        }
        """#
        let url = URL(string: "http://localhost:8081/recipe/not-an-uuid")
        let request = URLRequest(url: url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }

    @Test("Delete on path /recipe/not-an-uuid should return 400 bad request")
    func deleteOnPathRecipeWithUnInvalidUUIDShouldReturn400BadRequest() async throws {

        // Arrange.
        let expectedStatusCode = 400
        let expectedResponse = #"""
        {
          "error" : true,
          "reason" : "Bad Request"
        }
        """#
        let url = URL(string: "http://localhost:8081/recipe/not-an-uuid")
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }

    @Test("Delete on path /recipe/{uuid} should return 204 and remove recipe")
    func deleteOnPathRecipeShouldReturn200AndRemoveRecipe() async throws {

        // Arrange.
        let id = UUID()
        let json = """
        {
          "id" : "\(id.uuidString)",
          "name" : "Raclette",
          "steps" : []
        }
        """
        let jsonData = Data(json.utf8)
        let postUrl = URL(string: "http://localhost:8081/recipe")!
        var postRequest = URLRequest(url: postUrl)
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.httpBody = jsonData
        _ = try await URLSession.shared.data(for: postRequest)

        let deleteUrl = URL(string: "http://localhost:8081/recipe/\(id.uuidString)")!
        var deleteRequest = URLRequest(url: deleteUrl)
        deleteRequest.httpMethod = "DELETE"
        let (_, deleteResponse) = try await URLSession.shared.data(for: deleteRequest)
        let deleteHttpResponse = deleteResponse as? HTTPURLResponse

        // Act.
        let actualDeleteStatusCode = deleteHttpResponse?.statusCode

        let getUrl = URL(string: "http://localhost:8081/recipe/\(id.uuidString)")!
        let getRequest = URLRequest(url: getUrl)
        let (_, getResponse) = try await URLSession.shared.data(for: getRequest)
        let getHttpResponse = getResponse as? HTTPURLResponse
        let actualGetStatusCode = getHttpResponse?.statusCode

        // Assert.
        #expect(actualDeleteStatusCode == 204)
        #expect(actualGetStatusCode == 404)
    }

    @Test("Delete on path /recipe/unknown-uuid should return 204")
    func deleteOnPathRecipeWithUnknownIdShouldReturn404() async throws {

        // Arrange.
        let url = URL(string: "http://localhost:8081/recipe/00000000-0000-0000-0000-000000000000")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode

        // Assert.
        #expect(actualStatuscode == 204)
    }

    @Test("Post on path /recipe with invalid json should return 400")
    func postOnPathRecipeWithInvalidJSONShouldReturn400() async throws {

        // Arrange.
        let expectedStatusCode = 400
        let expectedResponse = #"""
        {
          "error" : true,
          "reason" : "Bad Request"
        }
        """#
        let json = #"{"id":"A68A66C6-670B-4D48-8B25-8F9A61FD8E9D","nameee":"Pizza with ananas"}"#
        let jsonData = Data(json.utf8)

        let url = URL(string: "http://localhost:8081/recipe")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        // Act.
        let actualStatuscode = httpResponse?.statusCode
        let actualResponse = String(data: data, encoding: .utf8)!

        // Assert.
        #expect(expectedStatusCode == actualStatuscode)
        #expect(expectedResponse == actualResponse)
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
