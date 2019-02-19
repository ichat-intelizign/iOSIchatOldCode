//
//  ActionlinkMapping.swift
//  iChat
//
//  Created by Rahul Maurya on 10/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Actionlink: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = String.random()
        }
            self.label = values["label"].string
            self.params = values["params"].string
    }
}
