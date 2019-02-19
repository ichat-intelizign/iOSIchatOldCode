import Foundation
import SwiftyJSON
import RealmSwift
import UserNotifications

final class PushManager {
    static let delegate = UserNotificationCenterDelegate()

    static let kDeviceTokenKey = "deviceToken"
    static let kPushIdentifierKey = "pushIdentifier"

    static var lastNotificationRoomId: String?

    static func updatePushToken() {
        guard let deviceToken = getDeviceToken() else { return }
        guard let userIdentifier = AuthManager.isAuthenticated()?.userId else { return }

        let request = [
            "msg": "method",
            "method": "raix:push-update",
            "params": [[
                "id": getOrCreatePushId(),
                "userId": userIdentifier,
                "token": ["apn": deviceToken],
                "appName": Bundle.main.bundleIdentifier ?? "main",
                "metadata": [:]
                ]]
            ] as [String: Any]

        SocketManager.send(request)
    }

    static func updateUser(_ userIdentifier: String) {
        let request = [
            "msg": "method",
            "method": "raix:push-setuser",
            "userId": userIdentifier,
            "params": [getOrCreatePushId()]
            ] as [String: Any]

        SocketManager.send(request)
    }

    fileprivate static func getOrCreatePushId() -> String {
        guard let pushId = UserDefaults.standard.string(forKey: kPushIdentifierKey) else {
            let randomId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(randomId, forKey: kPushIdentifierKey)
            return randomId
        }

        return pushId
    }

    static func getDeviceToken() -> String? {
        guard let deviceToken = UserDefaults.standard.string(forKey: kDeviceTokenKey) else {
            return nil
        }
        print("device token- \(deviceToken)")
        return deviceToken
    }

}

// MARK: Handle Notifications

struct PushNotification {
    let host: String
    let username: String
    let roomId: String
    let roomType: SubscriptionType

    init?(raw: [AnyHashable: Any]) {
        guard
            let json = JSON(parseJSON: (raw["ejson"] as? String) ?? "").dictionary,
            let host = json["host"]?.string,
            let username = json["sender"]?["username"].string,
            let roomType = json["type"]?.string,
            let roomId = json["rid"]?.string
            else {
                return nil
        }

        self.host = host
        self.username = username
        self.roomId = roomId
        self.roomType = SubscriptionType(rawValue: roomType) ?? .group
    }
}

// MARK: Categories

extension UNNotificationAction {
    static var reply: UNNotificationAction {
        return UNTextInputNotificationAction(
            identifier: "REPLY",
            title: "Reply",
            options: .authenticationRequired
        )
    }
}

extension UNNotificationCategory {
    static var message: UNNotificationCategory {
        return UNNotificationCategory(
            identifier: "MESSAGE",
            actions: [.reply],
            intentIdentifiers: [],
            options: []
        )
    }

    static var messageNoReply: UNNotificationCategory {
        return UNNotificationCategory(
            identifier: "REPLY",
            actions: [.reply],
            intentIdentifiers: [],
            options: []
        )
    }
}

extension PushManager {
    static func setupNotificationCenter() {
        let notificationCenter = UNUserNotificationCenter.current()
//        if #available(iOS 10.0, *) {
//            let center = UNUserNotificationCenter.current()
//            center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
//          ////  center.removeAllDeliveredNotifications() // To remove all delivered notifications
//        } else {
//            UIApplication.shared.cancelAllLocalNotifications()
//        }
        notificationCenter.delegate = PushManager.delegate
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        notificationCenter.setNotificationCategories([.message, .messageNoReply])
    }

    @discardableResult
    static func handleNotification(raw: [AnyHashable: Any], reply: String? = nil) -> Bool {
        guard let notification = PushNotification(raw: raw) else { return false }
        return handleNotification(notification, reply: reply)
    }

    @discardableResult
    static func handleNotification(_ notification: PushNotification, reply: String? = nil) -> Bool {
         let defaultURL = "ichatdev.intelizi.com"
        var serverURL: URL? {
            return  URL(string: defaultURL, scheme: "https")
        }
        //    let serverUrl = URL(string: notification.host)?.socketURL()?.absoluteString,
        _ = DatabaseManager.serverIndexForUrl("https://ichat.intelizi.com/")
        print("notification:\(notification)")
        // side effect: needed for Subscription.notificationSubscription()
        lastNotificationRoomId = notification.roomId

        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController {
            if let nav = main.centerViewController as? UINavigationController {
                if  let viewcpntroller = nav.viewControllers.first as? ChatViewController {
                    viewcpntroller.subscription = Subscription.notificationSubscription()
                    viewcpntroller.closeSidebarAfterSubscriptionUpdate = true
                    let navigationBarAppearace = UINavigationBar.appearance()
                    navigationBarAppearace.tintColor = UIColor.white
                }
            }
        } else {
            let controller1 = ChatViewController.shared
            controller1?.subscription = Subscription.notificationSubscription()
            let storyboardChat = UIStoryboard(name: "Chat", bundle: Bundle.main)
            let controller = storyboardChat.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.keyWindow {
                window.rootViewController = controller
                let controller1 = ChatViewController.shared
                controller1?.closeSidebarAfterSubscriptionUpdate = true
                controller1?.subscription = Subscription.notificationSubscription()
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.white
            }
        }

         //   ChatViewController.shared?.subscription = Subscription.notificationSubscription()
           // WindowManager.open(.chat)
        

        if let reply = reply {
            let appendage = notification.roomType == .directMessage ? "" : " @\(notification.username)"
            
            let message = "\(reply)\(appendage)"

            let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            API.shared.fetch(PostMessageRequest(roomId: notification.roomId, text: message)){ result in
                DispatchQueue.main.async {
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                }
                }
        }
        return true
    }
}

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushManager.handleNotification(
            raw: response.notification.request.content.userInfo,
            reply: (response as? UNTextInputNotificationResponse)?.userText
        )
    }
}
