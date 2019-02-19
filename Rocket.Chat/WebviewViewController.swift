//
//  WebviewViewController.swift
//  iChat
//
//  Created by Rahul Maurya on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import AVFoundation
import JitsiMeet
//import JitsiMeet
class WebviewViewController: UIViewController,JitsiMeetViewDelegate  {


//    let viewModel = JitsiViewModel()
//    let timer = Timer()
    var objParam = ""
    @IBOutlet weak var jitsiMeetView: JitsiMeetView?

//    deinit {
//        timer.invalidate()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        AnalyticsManager.log(event: .jitsiVideoCall(
//            subscriptionType: viewModel.analyticsSubscriptionType,
//            server: viewModel.analyticsServerURL
//            ))

        // Jitsi Update Call needs to be called every 10 seconds to make sure
        // call is not ended and is available to web users.
//        updateJitsiTimeout()
//        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
//            self?.updateJitsiTimeout()
//        }
//
        let view = self.view as? JitsiMeetView

        view?.delegate = self

        let plainString = "uid=\(AuthManager.currentUser()?.username ?? "")"
        let data = (plainString).data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        // As this is the Jitsi Meet app (i.e. not the Jitsi Meet SDK), we do want
        // the Welcome page to be enabled. It defaults to disabled in the SDK at the
        // time of this writing but it is clearer to be explicit about what we want
        var urlString: String = "https://talkexdvc.intelizi.com/\(objParam)"
        let urlString2: String = "https://talkexdvc.intelizi.com/zzz"
//https://3.8.228.223/test
        // append params
        urlString = "\(urlString)?\(base64)"
        print("urlstring-\(urlString)")
       // var finalURL = URL(string: urlString)
       // let finalURL = url.stringByAppendingPathComponent(base64String)
        // anyway.
        
        view?.welcomePageEnabled = false




//        jitsiMeetView?.delegate = self
        let defaults = UserDefaults.standard
        defaults.set(AuthManager.currentUser()?.displayName(), forKey: "displayname")
        view?.loadURLObject([
            "config": [
                "startWithAudioMuted": true,
                "startWithVideoMuted": false
            ],
            "context": [
                "user": [
                    "avatar": "https:/gravatar.com/avatar/abc123",
                    "displayname": "John Doe",
                    "email": "jdoe@example.com",
                    "id": "10712"
                ],
                "iss": "rocketchat-ios"
            ],
            "url": urlString2
            ])
       // https://ichat-vc.intelizi.com/\(objParam)
        //https://ichat-vc.intelizi.com/iChat1f448a1565b21cf66b6111091c9d6a77?dWlkPTEwNzEy
//addPeopleEnabled
////
        let Button = UIButton(frame: CGRect(x: 3, y: 15, width: 30, height: 30))
        //Button.center.x = self.view.center.x
        Button.tintColor = UIColor.white
       Button.addTarget(self, action: #selector(WebviewViewController.closeview(_:)), for:.touchUpInside)

        //label.center = CGPoint(x: 8, y: 22)
        Button.setTitle("X",for: .normal)
        //Button.textAlignment = .center
      //  Button.text = AuthManager.currentUser()?.displayName()
        self.view.addSubview(Button)
        self.view.bringSubview(toFront: Button)
    }



    @objc func closeview(_ sender : UIButton) {
        DispatchQueue.main.async { // Correct
            if let mainWindow = UIApplication.shared.delegate?.window {
                mainWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                self.view?.removeFromSuperview()
                //self.onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data: data)
            }
        }

    }


//    func onJitsiMeetViewDelegateEvent(name: String, data: [AnyHashable: Any]) {
//        Log.debug("[\(#file):\(#line)] JitsiMeetViewDelegate \(name) \(data)")
//    }
//
//    func conferenceFailed(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_FAILED", data: data)
//        Log.debug("conference Failed log is : \(data)")
//    }
//
//    func conferenceJoined(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_JOINED", data: data)
//        Log.debug("conference Joined log is : \(data)")
//    }
//
//    func conferenceLeft(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data: data)
//        Log.debug("conference Left log is : \(data)")
//      //  close()
//    }
//
//    func conferenceWillJoin(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data: data)
//        Log.debug("conference Join log is : \(data)")
//    }
//
//    func conferenceWillLeave(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_LEAVE", data: data)
//        Log.debug("conference Leave log is : \(data)")
//     //   close()
//    }
//
//    func loadConfigError(_ data: [AnyHashable: Any]) {
//        onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data: data)
//        Log.debug("conference Error log is : \(data)")
//    }

    #if DEBUG
    func onJitsiMeetViewDelegateEvent(name: String?, data: [AnyHashable : Any]?) {
    if let data = data {
    print("[\(#file):\(#line)] JitsiMeetViewDelegate \(name ?? "") \(data)")
    }
    }


    func conferenceFailed(_ data: [AnyHashable : Any]?) {
    onJitsiMeetViewDelegateEvent(name: "CONFERENCE_FAILED", data: data)
//    if let mainWindow = UIApplication.shared.delegate?.window {
//    mainWindow?.rootViewController?.dismiss(animated: true, completion: nil)
//    }
    }

    func conferenceJoined(_ data: [AnyHashable : Any]?) {
    onJitsiMeetViewDelegateEvent(name: "CONFERENCE_JOINED", data: data)
    print("after joindata\(data)")
    }

    func conferenceLeft(_ data: [AnyHashable : Any]?) {
    DispatchQueue.main.async { // Correct
    if let mainWindow = UIApplication.shared.delegate?.window {
    mainWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    self.view?.removeFromSuperview()
    self.onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data: data)
    }

    //self.view? = nil
    }




    }

    func conferenceWillJoin(_ data: [AnyHashable : Any]?) {
    onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data: data)
    }

    func conferenceWillLeave(_ data: [AnyHashable : Any]?) {
    onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_LEAVE", data: data)
    }
//    func enterPicture(inPicture data: [AnyHashable : Any]!) {
//    DispatchQueue.main.async {
//   // self.jitsiMeetView?.inPicture()
//    }
//    }

    func loadConfigError(_ data: [AnyHashable : Any]?) {
    onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data: data)
    }

    #endif



//    func updateJitsiTimeout() {
//        guard let subscription = self.viewModel.subscription else { return }
//        SubscriptionManager.updateJitsiTimeout(rid: subscription.rid)
//    }
//
//    func close() {
//        timer.invalidate()
//
//        jitsiMeetView?.removeFromSuperview()
//        jitsiMeetView = nil
//
//        dismiss(animated: true, completion: nil)
//    }

}

extension URL {

    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }

        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // append the new query item in the existing query items array
        queryItems.append(queryItem)

        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)

        // returns the url from new url components
        return urlComponents.url!
    }
}

// MARK: JitsiMeetViewDelegate




