//
//  SubscriptionUserStatusView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionUserStatusViewProtocol: class {
    func userDidPressedOption()
}

final class SubscriptionUserStatusView: UIView {
     var activityIndicator: LoaderView!
     @IBOutlet weak var viewLogout: UIView! {
        didSet {
    viewLogout.layer.borderColor = UIColor.RCLightBlue().cgColor
    viewLogout.layer.borderWidth = 1
    }
    }
    @IBOutlet weak var viewOnlineborder: UIView! {
    didSet {
    viewOnlineborder.layer.cornerRadius = 4
    viewOnlineborder.layer.borderColor = UIColor.RCOnline().cgColor
    viewOnlineborder.layer.borderWidth = 1
    }
    }
    @IBOutlet weak var viewAwayborder: UIView! {
    didSet {
    viewAwayborder.layer.cornerRadius = 4
    viewAwayborder.layer.borderColor = UIColor.RCAway().cgColor
    viewAwayborder.layer.borderWidth = 1
    }
    }
    @IBOutlet weak var viewBusyborder: UIView! {
        didSet {
            viewBusyborder.layer.cornerRadius = 4
            viewBusyborder.layer.borderColor = UIColor.RCBusy().cgColor
            viewBusyborder.layer.borderWidth = 1
        }
    }
    weak var delegate: SubscriptionUserStatusViewProtocol?
    weak var parentController: UIViewController?

    @IBOutlet weak var buttonOnline: UIButton!
    @IBOutlet weak var labelOnline: UILabel! {
        didSet {
            labelOnline.text = localized("user_menu.online")
        }
    }
   @IBOutlet weak var buttonAway: UIView!
    @IBOutlet weak var labelAway: UILabel! {
        didSet {
            labelAway.text = localized("user_menu.away")
        }
    }

    @IBOutlet weak var buttonBusy: UIView!
    @IBOutlet weak var labelBusy: UILabel! {
        didSet {
            labelBusy.text = localized("user_menu.busy")
        }
    }

    @IBOutlet weak var buttonInvisible: UIView!
    @IBOutlet weak var labelInvisible: UILabel! {
        didSet {
            labelInvisible.text = localized("user_menu.invisible")
        }
    }

    @IBOutlet weak var buttonSettings: UIView!
    @IBOutlet weak var labelSettings: UILabel! {
        didSet {
            labelSettings.text = localized("user_menu.settings")
        }
    }

    @IBOutlet weak var imageViewSettings: UIImageView! {
        didSet {
            imageViewSettings.image = imageViewSettings.image?.imageWithTint(.RCLightBlue())
        }
    }

    @IBOutlet weak var buttonLogout: UIView!
    @IBOutlet weak var labelLogout: UILabel! {
        didSet {
            labelLogout.text = localized("user_menu.logout")
        }
    }

    @IBOutlet weak var imageViewLogout: UIImageView! {
        didSet {
            imageViewLogout.image = imageViewLogout.image?.imageWithTint(.RCLightBlue())
        }
    }

    // MARK: IBAction

    @IBAction func buttonOnlineDidPressed(_ sender: Any) {
        UserManager.setUserStatus(status: .online) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonAwayDidPressed(_ sender: Any) {
        UserManager.setUserStatus(status: .away) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonBusyDidPressed(_ sender: Any) {
        UserManager.setUserStatus(status: .busy) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonInvisibleDidPressed(_ sender: Any) {
        UserManager.setUserStatus(status: .offline) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonSettingsDidPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)

        if let controller = storyboard.instantiateInitialViewController() {
            controller.modalPresentationStyle = .formSheet
            parentController?.present(controller, animated: true, completion: nil)
        }

        self.delegate?.userDidPressedOption()
    }


    @IBAction func showMyProfileAction(_ sender: Any) {
        guard let currentUser = AuthManager.currentUser() else { return }
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ChannelInfoViewController") as? ChannelInfoViewController {
        controller.frommemberlist = "chatcell"
        controller.nameofuser = currentUser.username!
             let navigationVC = UINavigationController(rootViewController: controller)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
             appDelegate.window?.rootViewController!.present(navigationVC, animated: true, completion: nil)
        }
        }
    }

    @IBAction func buttonLogoutDidPressed(_ sender: Any) {
   //   self.activityIndicator.startAnimating()
        // RKS NOTE: I know that this isn't the best place, but we need to fix
        // this crash ASAP. In the future we may have a centered place for all
        // database notifications.
        if ((UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController) != nil) {
            if  UserDefaults.standard.value(forKey: "deviceToken") != nil {
                if let deviceToken = UserDefaults.standard.value(forKey: "deviceToken") as? String {
                    API.shared.fetch(PushTokenDeleteRequest(token: deviceToken, userID: "defaultpushuser")) { result in
                        print("API result push -\(result?.success ?? "no")")
                        DispatchQueue.main.async {
                           //   self.activityIndicator.startAnimating()
                            print("resulttokendelete\(String(describing: result))")
                                ChatViewController.shared?.messagesToken?.invalidate()
                            SubscriptionsViewController.shared?.currentUserToken?.invalidate()
                            SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()
                            AuthManager.logout {
                                let storyboardChat = UIStoryboard(name: "Auth", bundle: Bundle.main)
                                let controller = storyboardChat.instantiateInitialViewController()
                                let application = UIApplication.shared

                                if let window = application.keyWindow {
                                    window.rootViewController = controller
                                    window.makeKeyAndVisible()

                                }
                            }

                        }
                    }
                }

            } else {

                ChatViewController.shared?.messagesToken?.invalidate()
                SubscriptionsViewController.shared?.currentUserToken?.invalidate()
                SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()
                AuthManager.logout {
                let storyboardChat = UIStoryboard(name: "Auth", bundle: Bundle.main)
                let controller = storyboardChat.instantiateInitialViewController()
                let application = UIApplication.shared

                if let window = application.keyWindow {
                    window.rootViewController = controller
                    window.makeKeyAndVisible()
                }
                }
            }
        }  else {
            if  UserDefaults.standard.value(forKey: "deviceToken") != nil {
                if let deviceToken = UserDefaults.standard.value(forKey: "deviceToken") as? String {
                    API.shared.fetch(PushTokenDeleteRequest(token: deviceToken, userID: "defaultpushuser")) { result in
                        DispatchQueue.main.async {
                           //   self.activityIndicator.startAnimating()
                            print("resulttokendelete\(String(describing: result))")
//                            AuthManager.logout {
//                                AuthManager.recoverAuthIfNeeded()
                             //  AppManager.reloadApp()
//                            }

                                ChatViewController.shared?.messagesToken?.invalidate()
                                SubscriptionsViewController.shared?.currentUserToken?.invalidate()
                                SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()
                             AuthManager.logout {
                                let storyboardChat = UIStoryboard(name: "Auth", bundle: Bundle.main)
                                let controller = storyboardChat.instantiateInitialViewController()
                                let application = UIApplication.shared

                                if let window = application.keyWindow {
                                    window.rootViewController = controller
                                    window.makeKeyAndVisible()
                                }
                            }

                        }
                    }
                }

            } else {
                ChatViewController.shared?.messagesToken?.invalidate()
                SubscriptionsViewController.shared?.currentUserToken?.invalidate()
                SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()
                AuthManager.logout {
                let storyboardChat = UIStoryboard(name: "Auth", bundle: Bundle.main)
                let controller = storyboardChat.instantiateInitialViewController()
                let application = UIApplication.shared

                if let window = application.keyWindow {
                    window.rootViewController = controller
                    window.makeKeyAndVisible()
                }
                }
                
            }

        }

      //  MainChatViewController.shared?.logout()

    }

}
