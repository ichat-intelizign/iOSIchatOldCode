//
//  alluserlist.swift
//  iChat
//
//  Created by Rahul Maurya on 30/01/19.
//  Copyright © 2019 Intelizign. All rights reserved.
//

import SwiftyJSON
typealias UserlistResult = APIResult<Alluserlist>

class Alluserlist: APIRequest {
    let method: String = "GET"
    let path: String = "/api/v1/users.list"
}

extension APIResult where T == Alluserlist {
    var success: Bool? {
        return raw?["success"].boolValue
    }
    var alluser: [AllUserModel]? {
        return raw?["users"].arrayValue.map {
            let alluser = AllUserModel()
            alluser.map($0, realm: nil)
            return alluser
            }.flatMap { $0 }
    }

//    var name: String? {
//        return alluser?["name"].string
//    }
//    var username: String? {
//        return alluser?["username"].string
//    }
}

