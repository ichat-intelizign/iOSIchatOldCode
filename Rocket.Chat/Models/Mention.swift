//
//  Mention.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

final class Mention: BaseModel {
    @objc dynamic var username: String?
     @objc dynamic var fname: String?
    @objc dynamic var userId: String?
    @objc dynamic var realName: String?
}
