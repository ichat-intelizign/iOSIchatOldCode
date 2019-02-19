//
//  APITestCase.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat
//https://ichat.intelizi.com/
class APITestCase: XCTestCase {
    let api: API! = API(host: "https://ichat.intelizi.com/")
}
