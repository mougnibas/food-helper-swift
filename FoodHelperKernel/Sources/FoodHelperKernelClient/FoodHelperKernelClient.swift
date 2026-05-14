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

/// Http client implementation of `FoodHelperKernel` service.
public actor FoodHelperKernelClient: FoodHelperKernel {

    private let baseURL: URL
    private let loader: DataLoading

    public init() {
        self.baseURL = URL(string: "http://localhost:8080")!
        self.loader = URLSession.shared
    }

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.loader = URLSession.shared
    }

    public init(baseURL: URL, loader: DataLoading) {
        self.baseURL = baseURL
        self.loader = loader
    }

    public func getAllRecipes() async throws(FoodHelperKernelError) -> [Recipe] {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/kernel/recipe")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"

            // Send request.
            let (data, _) = try await loader.data(for: request)

            // Fetch result.
            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
            return recipes
        } catch {
            throw .cantAccessData
        }
    }

    public func getRecipeById(id: UUID) async throws(FoodHelperKernelError) -> Recipe? {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/kernel/recipe/\(id)")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"

            // Send request.
            let (data, response) = try await loader.data(for: request)
            let httpResponse = response as? HTTPURLResponse

            // Fetch result.
            switch httpResponse?.statusCode {
            case 200:
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                return recipe
            case 404, _:
                return nil
            }
        } catch {
            throw .cantAccessData
        }
    }

    public func addRecipe(recipe: Recipe) async throws(FoodHelperKernelError) {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/kernel/recipe")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(recipe)

            // Send request.
            _ = try await loader.data(for: request)
        } catch {
            throw .cantAccessData
        }
    }

    public func deleteRecipeById(id: UUID) async throws(FoodHelperKernelError) {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/kernel/recipe/\(id)")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "DELETE"

            // Send request.
            let (_, _) = try await loader.data(for: request)
        } catch {
            throw .cantAccessData
        }
    }

    public func getWelcomeMessage() async throws(FoodHelperKernelError) -> String {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"

            // Send request.
            let (data, _) = try await loader.data(for: request)

            // Fetch result.
            return String(bytes: data, encoding: String.Encoding.utf8)!
        } catch {
            throw .cantAccessData
        }
    }

    public func getHealthLive() async throws(FoodHelperKernelError) -> Bool {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/health/live")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"

            // Send request.
            let (_, response) = try await loader.data(for: request)

            // Fetch result.
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            throw .cantAccessData
        }
    }

    public func getHealthReady() async throws(FoodHelperKernelError) -> Bool {

        do {
            // Build URL.
            let url = URL(string: "\(baseURL)/health/ready")

            // Request.
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"

            // Send request.
            let (_, response) = try await loader.data(for: request)

            // Fetch result.
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

}
