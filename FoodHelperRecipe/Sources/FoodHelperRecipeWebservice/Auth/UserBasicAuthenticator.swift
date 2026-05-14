// GNU AFFERO GENERAL PUBLIC LICENSE
// Version 3, 19 November 2007
//
// Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
// Everyone is permitted to copy and distribute verbatim copies
// of this license document, but changing it is not allowed.

import Foundation

import Vapor

struct UserBasicAuthenticator: AsyncBasicAuthenticator {

    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        if basic.username == "user" && basic.password == "secret" {
            request.auth.login(User(name: "Authenticated test user"))
        }
    }

}
