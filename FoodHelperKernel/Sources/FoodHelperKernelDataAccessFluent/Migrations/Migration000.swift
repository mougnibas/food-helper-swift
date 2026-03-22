// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Fluent

/// Fluent Migration #000.
public struct Migration000: AsyncMigration {

    public init() {}

    public func prepare(on database: Database) async throws {

        // Create Recipe table.
        try await database.schema(RecipeModel.schema)
            .id()
            .field("name", .string, .required)
            .create()

        // Create Step table.
        try await database.schema(StepModel.schema)
            .id()
            .field("index", .int, .required)
            .field("title", .string, .required)
            .field("instructions", .array(of: .string), .required)
            .field("recipe_id", .uuid, .required, .references(RecipeModel.schema, "id", onDelete: .cascade))
            .create()

        // Create Food table.
        try await database.schema(FoodModel.schema)
            .id()
            .field("index", .int, .required)
            .field("name", .string, .required)
            .field("quantity", .int, .required)
            .field("unit", .string, .required)
            .field("step_id", .uuid, .required, .references(StepModel.schema, "id", onDelete: .cascade))
            .create()
    }

    public func revert(on database: Database) async throws {

        // Delete Food table.
        try await database.schema(FoodModel.schema).delete()

        // Delete Step table.
        try await database.schema(StepModel.schema).delete()

        // Delete Recipe table.
        try await database.schema(RecipeModel.schema).delete()
    }
}
