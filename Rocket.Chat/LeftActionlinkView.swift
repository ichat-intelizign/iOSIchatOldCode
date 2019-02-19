//
//  LeftActionlinkView.swift
//  iChat
//
//  Created by Rahul Maurya on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class LeftActionlinkView: UIView {
    static let defaultHeight = CGFloat(80)
    var stringParma : String?
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnClicktoJoin: UIButton! {
        didSet {
            btnClicktoJoin.layer.cornerRadius = 3.0
            btnClicktoJoin.layer.borderWidth = 1
            btnClicktoJoin.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    @IBAction func btnVideoClick(_ sender: Any) {
//        let refreshAlert = UIAlertController(title: "", message: "Video chat comming soon..", preferredStyle: UIAlertControllerStyle.actionSheet)
//
//        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//            print("Handle Ok logic here")
//            //                application.open(URL(string: "https://itunes.apple.com/us/app/jitsi-meet/id1165103905?mt=8")!)
//
//        }))
//
//        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//            print("Handle Cancel Logic here")
//        }))
//
//        window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "webview", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "WebviewViewController") as? WebviewViewController
        newViewController?.objParam = stringParma!
        self.window?.rootViewController?.present(newViewController!, animated: true, completion: nil)
//        let inputURL = NSURL(string: "org.jitsi.meet://ichat-vc.intelizi.com/\(stringParma ?? "")")
//
//        let application = UIApplication.shared
//
//        if application.canOpenURL((inputURL)! as URL) {
//            application.open(inputURL! as URL)
//        } else {
////https://itunes.apple.com/us/app/jitsi-meet/id1165103905?mt=8
//            // if Youtube app is not installed, open URL inside Safari
//
//            let refreshAlert = UIAlertController(title: "", message: "You need to install 'Jitsi Meet' app , Do you want to install?", preferredStyle: UIAlertControllerStyle.actionSheet)
//
//            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle Ok logic here")
//                application.open(URL(string: "https://itunes.apple.com/us/app/jitsi-meet/id1165103905?mt=8")!)
//
//            }))
//
//            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//                print("Handle Cancel Logic here")
//            }))
//
//            window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
//
//        }

      //  UIApplication.shared.openURL(inputURL!)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
