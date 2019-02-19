//
//  AppDelegate.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/5/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import FirebaseCore
import JitsiMeet
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
       // RTCInitializeSSL()
        let navigationBarAppearace = UINavigationBar.appearance()
         navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = UIColor(rgb: 0x58D1E9, alphaVal: 1)
        
        // Back buttons and such
       // navigationBarAppearace.barTintColor = UIColor.YourBackgroundColor()  // Bar's background color
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]  // Title's text color

        //IQKeyboardManager.sharedManager().enable = true
        PushManager.setupNotificationCenter()
        application.registerForRemoteNotifications()
        if let launchOptions = launchOptions,
            let notification = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
            PushManager.handleNotification(raw: notification)
        }
         Launcher().prepareToLaunch(with: launchOptions)
        FIRApp.configure()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.opensub), name: Notification.Name("postimage"), object: nil)
        return true
    }

    // MARK: AppDelegate LifeCycle

    func applicationDidBecomeActive(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
       // SocketManager.reconnect()
    }


    func applicationWillTerminate(_ application: UIApplication) {
        SubscriptionManager.updateUnreadApplicationBadge()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SubscriptionManager.updateUnreadApplicationBadge()
      


        if AuthManager.isAuthenticated() != nil {
            UserManager.setUserPresence(status: .away) { (_) in
              //  SocketManager.disconnect({ (_, _) in })
            }
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
    }


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return JitsiMeetView.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return JitsiMeetView.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    


    // MARK: Remote Notification

//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        Log.debug("Notification: \(userInfo)")
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        Log.debug("Notification: \(userInfo)")
//    }


    @objc func opensub() {
        let storyboard = UIStoryboard(name: "Subscriptions", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Subscriptions") as? SubscriptionsViewController
        self.window?.rootViewController?.present(vc!, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.standard.set(deviceToken.hexString, forKey: PushManager.kDeviceTokenKey)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("Fail to register for notification: \(error)")
    }

}
