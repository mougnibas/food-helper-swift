// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

public struct Food: Codable, Equatable, Sendable {

    /// Name if the food.
    public let name: String

    /// Quantity of the food.
    public let quantity: Int

    /// Unit of the food (g, etc.).
    public let unit: UnitMeasurement

    public init (name: String, quantity: Int, unit: UnitMeasurement) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
