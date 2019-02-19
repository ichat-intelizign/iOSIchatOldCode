//
//  PushTokenDeleteRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias PushTokenDeleteResult = APIResult<PushTokenDeleteRequest>

 class PushTokenDeleteRequest: APIRequest {


    let method: String = "POST"
    //let path = "/api/v1/login"
    let path = "/api/v1/users.resetPushToken"

    let token: String
    let userID: String
    init(token: String, userID: String) {
        self.token = token
        self.userID = userID
    }

    func body() -> Data? {
        let body = JSON([
            "id": token,
            "userId": userID //defaultpushuser
            ])

        return body.rawString()?.data(using: .utf8)
    }
}

extension APIResult where T == PushTokenDeleteRequest {
    var success: String? {
        return raw?["success"].string
    }
}
