//
//  ChannelInfoDetailCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import Fontello_Swift
struct ChannelInfoDetailCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoDetailCell.self
    let title: String
    let detail: String
    let useridN: String
    let timeText: String
    let mailText: String
    let callText: String
    let building: String
    let location: String
    let loginText: String
    let action: (() -> Void)?
    init(title: String, detail: String = "",useridN: String,timeText: String,mailText: String,callText: String,building: String,location: String,loginText: String , action: (() -> Void)? = nil) {
        self.title = title
        self.detail = detail
        self.action = action
        self.useridN = useridN
        self.timeText = timeText
        self.mailText = mailText
        self.callText = callText
        self.building = building
        self.location = location
        self.loginText = loginText
        }
}

class ChannelInfoDetailCell: UITableViewCell, ChannelInfoCellProtocol {
    static let identifier = "kChannelInfoCellDetail"
    static let defaultHeight: Float = 238
    var data: ChannelInfoDetailCellData? {
        didSet {
           // labelTitle.text = data?.title
            //abelDetail.text = data?.detail
            print("data1 \(data?.callText)")
            print("data1 \(data?.useridN)")
            lblCallText.text = data?.callText
            labelTitle.text = data?.useridN
        }
    }
    @IBOutlet weak var lblTime: UILabel! {
        didSet {
            lblTime.font = FontAwesome.fontOfSize(17)
            lblTime.text = FontAwesome.stringWithName(.Clock)
        }
    }
    @IBOutlet weak var lblbuilding: UILabel! {
        didSet {
            lblbuilding.font = FontAwesome.fontOfSize(17)
            lblbuilding.text = FontAwesome.stringWithName(.Building)
        }
    }
    @IBOutlet weak var lblLastLogin: UILabel! {
        didSet {
            lblLastLogin.font = FontAwesome.fontOfSize(17)
            lblLastLogin.text = FontAwesome.stringWithName(.Login)
        }
    }
     @IBOutlet weak var lblCall: UILabel! {
        didSet {
            lblCall.font = FontAwesome.fontOfSize(17)
            lblCall.text = FontAwesome.stringWithName(.Phone)
        }
    }
    @IBOutlet weak var lblMail: UILabel! {
        didSet {
            lblMail.font = FontAwesome.fontOfSize(17)
            lblMail.text = FontAwesome.stringWithName(.Mail)
        }
    }
    @IBOutlet weak var lblShield: UILabel! {
        didSet {
            lblShield.font = FontAwesome.fontOfSize(17)
            lblShield.text = FontAwesome.stringWithName(.Shield)
        }
    }
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var lblTimeText: UILabel!
    @IBOutlet weak var lblMailText: UILabel!
    @IBOutlet weak var lblCallText: UILabel! {
    didSet {
        lblCallText.textColor = UIColor.white
    }
    }
    @IBOutlet weak var lblBuildingText: UILabel!
    @IBOutlet weak var lblLoginText: UILabel!
    @IBOutlet weak var labelDetail: UILabel! {
        didSet {
            labelDetail.textColor = UIColor.RCLightGray()
        }
    }

}
