// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

public struct Step: Codable, Equatable, Sendable {

    /// Title of this step.
    public let title: String

    /// Instruction(s) of this step.
    public let instructions: [String]

    /// Food(s) of this step.
    public let foods: [Food]

    public init(title: String, instructions: [String], foods: [Food]) {
        self.title = title
        self.instructions = instructions
        self.foods = foods
    }
}
