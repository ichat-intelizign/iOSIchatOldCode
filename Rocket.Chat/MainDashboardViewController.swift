//
//  MainDashboardViewController.swift
//  iChat
//
//  Created by Rahul Maurya on 24/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SideMenuController
class MainDashboardViewController: SideMenuController, SideMenuControllerDelegate {
    let socketHandlerToken = String.random(5)
    //var subscription: Subscription!
    static var shared: MainDashboardViewController? {
        return UIApplication.shared.windows.first?.rootViewController as? MainDashboardViewController
    }

    class func closeSideMenuIfNeeded() {
        if let instance = shared {
            if instance.sidePanelVisible {
                instance.toggle()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menunew")
        SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft

        if UIDevice.current.userInterfaceIdiom == .pad {
            SideMenuController.preferences.drawing.sidePanelWidth = 320
        } else {
            SideMenuController.preferences.drawing.sidePanelWidth = UIScreen.main.bounds.width -
            30
        }

        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.interaction.swipingEnabled = true
        SideMenuController.preferences.interaction.panningEnabled = true
        SideMenuController.preferences.animating.statusBarBehaviour = .slideAnimation
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        performSegue(withIdentifier: "showCenterController", sender: nil)
        performSegue(withIdentifier: "containSideMenu", sender: nil)
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sideMenuControllerWillHide(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.willHide()
    }

    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.didHide()
        SubscriptionsPageViewController.shared?.showSubscriptionsList(animated: false)
    }

    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.didReveal()
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifiertbl"), object: nil)
    }

    func sideMenuControllerWillReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.willReveal()

    }

    // MARK: Authentication & Server management

    func logout() {
        ChatViewController.shared?.messagesToken?.invalidate()
        SubscriptionsViewController.shared?.currentUserToken?.invalidate()
        SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()

        AuthManager.logout {
            let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboardChat.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.keyWindow {
                window.rootViewController = controller
                window.makeKeyAndVisible()
            }
        }
    }

    func openAddNewTeamController() {
        SocketManager.disconnect { (_, _) in
            self.performSegue(withIdentifier: "Auth", sender: nil)
        }
    }

    func changeSelectedServer(index: Int) {
        DatabaseManager.selectDatabase(at: index)
        DatabaseManager.changeDatabaseInstance(index: index)

        SocketManager.disconnect { (_, _) in
            let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboardChat.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.windows.first {
                window.rootViewController = controller
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainDashboardViewController: SocketConnectionHandler {
    func socketDidConnect(socket: SocketManager) {

    }

    func socketDidDisconnect(socket: SocketManager) {

    }

    func socketDidReturnError(socket: SocketManager, error: SocketError) {
        switch error.error {
        case .invalidUser:
            alert(title: localized("alert.socket_error.invalid_user.title"),
                  message: localized("alert.socket_error.invalid_user.message")) { _ in
                    self.logout()
            }
        default:
            break
        }
    }

    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}
