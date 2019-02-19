//
//  OAuthManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat
//https://ichat.intelizi.com/
//https://ichat.intelizi.com/
class OAuthManagerSpec: XCTestCase {
    func testCallbackURL() {
        let loginService = LoginService()
        loginService.service = "github"

        let serverURL: URL! = URL(string: "https://ichat.intelizi.com/")
        let expectedURL: URL! = URL(string: "https://ichat.intelizi.com//_oauth/github")

        XCTAssertEqual(OAuthManager.callbackURL(for: loginService, at: serverURL), expectedURL, "callbackURL returns expected url")
//change
        let malformedServerURL: URL! = URL(string: "ichat.intelizi.com")

        XCTAssertNil(OAuthManager.callbackURL(for: loginService, at: malformedServerURL), "callbackURL returns nil with malformed server URL")
    }

    func testState() {
        XCTAssertNotNil(OAuthManager.state(), "returns non nil state")
    }
}
