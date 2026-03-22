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

public protocol DataLoading: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
