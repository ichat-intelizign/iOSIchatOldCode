//
//  AlluserModelmapping.swift
//  iChat
//
//  Created by Rahul Maurya on 15/02/19.
//  Copyright © 2019 Intelizign. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension AllUserModel: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
//        if self.identifier == nil {
//            self.identifier = String.random()
//        }

        self.nameAll = values["name"].string ?? ""
         self.usernameAll = values["username"].string ?? ""
    }
}
