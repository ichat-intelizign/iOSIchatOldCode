//
//  DashboardViewController.swift
//  iChat
//
//  Created by Rahul Maurya on 09/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SideMenuController
import RealmSwift
class DashboardViewController:UIViewController {
    @IBOutlet weak var dashbardUserName: UILabel!
    var subscription: Subscription?
     let socketHandlerToken = String.random(5)
     var messagesToken: NotificationToken!
    var closeSidebarAfterSubscriptionUpdate = false
    @IBOutlet weak var lblTIming: UILabel!
    static var shared: DashboardViewController? {
        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainDashboardViewController {
            if let nav = main.centerViewController as? UINavigationController {
                return nav.viewControllers.first as? DashboardViewController
            }
        }

        return nil
    }
    deinit {
       // NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }
//    class func closeSideMenuIfNeeded() {
//        if let instance = shared {
//            if instance.sidePanelVisible {
//                instance.toggle()
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.fetch(UserInfoRequest(username: (AuthManager.currentUser()?.username)!)) { result in
            DispatchQueue.main.async {
                if let user = result?.name {
                    print("nameuser- \(user)")
                    self.dashbardUserName.text = user.components(separatedBy: " ").first
                }
                else {
                    self.dashbardUserName.text = AuthManager.currentUser()?.displayName().components(separatedBy: " ").first
                }
            }
        }
         NotificationCenter.default.post(name: Notification.Name("NotificationIdentifiertbl"), object: nil)
//        let auth: Auth? = AuthManager.isAuthenticated()
//        let newsubscription = auth?.subscriptions.filter("name = %@", AuthManager.currentUser()?.displayName() ?? "").first
//        // self.subscription = newsubscription
//        print("newtitlesubscription - \(newsubscription)")



//        navigationController?.isNavigationBarHidden = false
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = UIColor.white
//        navigationController?.navigationBar.tintColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)
        self.title = "iCHAT"
       // guard let subscription = self.subscription else { return }
       // self.dashbardUserName.text = AuthManager.currentUser()?.displayName()
        //        guard let auth = AuthManager.isAuthenticated() else { return }
//        let subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
//        if let subscription = subscriptions.first {
//            self.subscription = subscription
//        }
    
        let hour = NSCalendar.current.component(.hour, from: NSDate() as Date)

        switch hour {
        case 6..<12 : self.lblTIming.text = (NSLocalizedString("Good Morning", comment: "Good Morning"))
        case 12 : self.lblTIming.text = (NSLocalizedString("Good Noon", comment: "Good Noon"))
        case 13..<17 : self.lblTIming.text = (NSLocalizedString("Good Afternoon", comment: "Good Afternoon"))
        case 17..<22 : self.lblTIming.text = (NSLocalizedString("Good Evening", comment: "Good Evening"))
        default: self.lblTIming.text = (NSLocalizedString("Good Night", comment: "Good Night"))
        }
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white

        //SocketManager.reconnect()
//        Realm.executeOnMainThread({ (realm) in
//            // Clear database
//            realm.refresh()
// })
           
       // SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
//        performSegue(withIdentifier: "showCenterController", sender: nil)
//        performSegue(withIdentifier: "containSideMenu", sender: nil)
       // setupTitleView()
    }
    // MARK: SideMenuControllerDelegate
}





