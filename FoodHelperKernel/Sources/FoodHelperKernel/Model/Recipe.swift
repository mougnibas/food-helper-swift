// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

/// A simple model representing a recipe with a stable identity and a display name.
///
/// Conforms to:
/// - Identifiable: for stable identity in lists and collections
/// - Codable: for encoding/decoding (e.g., JSON, Property Lists)
/// - Equatable: for value comparison
/// - Sendable: for safe use across concurrency domains
public struct Recipe: Identifiable, Codable, Equatable, Sendable {

    /// The unique identifier for the recipe.
    public let id: UUID

    /// The human-readable name of the recipe.
    public let name: String

    /// Steps to do to make this recipe.
    public let steps: [Step]

    /// Creates a new recipe.
    /// - Parameters:
    ///   - name: The human-readable name of the recipe.
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.steps = []
    }

    /// Creates a new recipe.
    /// - Parameters:
    ///   - id: The unique identifier for the recipe. Defaults to a new UUID.
    ///   - name: The human-readable name of the recipe.
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
        self.steps = []
    }

    /// Creates a new recipe.
    /// - Parameters:
    ///   - id: The unique identifier for the recipe. Defaults to a new UUID.
    ///   - name: The human-readable name of the recipe.
    ///   - steps: Steps to do to make this recipe.
    public init(id: UUID, name: String, steps: [Step]) {
        self.id = id
        self.name = name
        self.steps = steps
    }

    /// `Equatable` protocol requirement.
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.steps == rhs.steps
    }
}
