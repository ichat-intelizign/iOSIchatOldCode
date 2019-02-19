//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SlackTextViewController
import SimpleImageViewer
import IQKeyboardManagerSwift

fileprivate typealias ListSegueData = (title: String, query: String?)
// swiftlint:disable file_length type_body_length
final class ChatViewController: SLKTextViewController, UIPopoverPresentationControllerDelegate {
    let picker = UIImageView(image: UIImage(named: ""))
    var arrPikcer = ["Starrred Messages","Mention Messages"]
    var autoresizing: UIViewAutoresizing?
    var activityIndicator: LoaderView!
    @IBOutlet weak var activityIndicatorContainer: UIView! {
        didSet {
            let width = activityIndicatorContainer.bounds.width
            let height = activityIndicatorContainer.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let activityIndicator = LoaderView(frame: frame)
            activityIndicatorContainer.addSubview(activityIndicator)
            self.activityIndicator = activityIndicator
        }
    }

    @IBOutlet weak var buttonScrollToBottom: UIButton!
    var buttonScrollToBottomMarginConstraint: NSLayoutConstraint?

    var showButtonScrollToBottom: Bool = false {
        didSet {
            self.buttonScrollToBottom.superview?.layoutIfNeeded()

            if self.showButtonScrollToBottom {
                self.buttonScrollToBottomMarginConstraint?.constant = -64
            } else {
                self.buttonScrollToBottomMarginConstraint?.constant = 50
            }
            if showButtonScrollToBottom != oldValue {
                UIView.animate(withDuration: 0.5) {
                    self.buttonScrollToBottom.superview?.layoutIfNeeded()
                }
            }
        }
    }

    weak var chatTitleView: ChatTitleView?
    weak var chatPreviewModeView: ChatPreviewModeView?
    weak var chatHeaderViewStatus: ChatHeaderViewStatus?
    var documentController: UIDocumentInteractionController?
    var arralluser = [AllUserModel]()
    var replyView: ReplyView!
    var replyString: String = ""

    var dataController = ChatDataController()
var searchResult: [AllUserModel] = []
   //var searchResult: [(String, Any)] = []
  var directMessageGroup1: [Subscription] = []
    var subscriptions1: Results<Subscription>?
    var closeSidebarAfterSubscriptionUpdate = false

    var isRequestingHistory = false
    var isAppendingMessages = false

    let socketHandlerToken = String.random(5)
    var messagesToken: NotificationToken!
    var messagesQuery: Results<Message>!
    var messages: [Message] = []
    var subscription: Subscription! {
        didSet {
            guard !subscription.isInvalidated else { return }

            updateSubscriptionInfo()
             createPicker()
            markAsRead()
            typingIndicatorView?.dismissIndicator()

            if let oldValue = oldValue, oldValue.identifier != subscription.identifier {
                unsubscribe(for: oldValue)
            }
        }
    }

    // MARK: View Life Cycle

    static var shared: ChatViewController? {
        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController {
            if let nav = main.centerViewController as? UINavigationController {
                return nav.viewControllers.first as? ChatViewController
            }
        }

        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().enable = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x58D1E9, alphaVal: 1)
        //navigationController?.navigationBar.tintColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "more"), for: .normal)
        btn2.imageView?.contentMode = .scaleAspectFit
        btn2.frame = CGRect(x: 0, y: 0, width: 10, height: 3)

        btn2.addTarget(self, action: #selector(ChatViewController.pickerSelect(_:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        item2.customView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.navigationItem.setRightBarButtonItems([item2], animated: true)
        collectionView?.isPrefetchingEnabled = true
        collectionView?.backgroundColor = UIColor(rgb: 0xF1F1F1, alphaVal: 1)
        isInverted = false
        bounces = true
        shakeToClearEnabled = true
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false

        leftButton.setImage(UIImage(named: "Upload"), for: .normal)

        rightButton.isEnabled = false

        setupTitleView()
        setupTextViewSettings()
        setupScrollToBottomButton()

        NotificationCenter.default.addObserver(self, selector: #selector(reconnect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        if !SocketManager.isConnected() {
            socketDidDisconnect(socket: SocketManager.sharedInstance)
        }

       // print("subsription\(subscription.messages)")

//        guard let auth = AuthManager.isAuthenticated() else { return }
//        let subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
//        if let subscription = subscriptions.first {
//            self.subscription = subscription
//        }

        view.bringSubview(toFront: activityIndicatorContainer)
        view.bringSubview(toFront: buttonScrollToBottom)
        view.bringSubview(toFront: textInputbar)

        if buttonScrollToBottomMarginConstraint == nil {
            buttonScrollToBottomMarginConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
            buttonScrollToBottomMarginConstraint?.isActive = true
        }

        setupReplyView()
        callAlluserlist()

    }

    @objc func pickerSelect(_ sender: UIButton)
    {
        picker.isHidden ? openPicker() : closePicker()
    }

   func callAlluserlist(){
    API.shared.fetch(Alluserlist()) {  result in
    DispatchQueue.main.async {
        self.activityIndicator.stopAnimating()
        self.activityIndicatorContainer.isHidden = true

        self.arralluser = (result?.alluser)!

//    if let username = result?.username {
//    print("usernamechaview- \(username)")
//   // self.labelTitle.text = username
//    }

//    if let id = result?.username {
//    let auth: Auth? = AuthManager.isAuthenticated()
//    let newsubscription = auth?.subscriptions.filter("name = %@", id).first
//    self.subscription = newsubscription
//    print("newsubscription - \(newsubscription)")
//    self.updateButtonFavoriteImage()
//    }
    //  Auth?.subscriptions.filter("rid = %@", roomId).first
    }
    }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }

     func createPicker() {

        picker.frame = CGRect(x: view.frame.maxX - 250, y: -1, width: 200, height: 160)
        picker.alpha = 1
        picker.isHidden = true
        picker.isUserInteractionEnabled = true
        picker.backgroundColor = UIColor.white
        var offset = 18

        for (index, feeling) in arrPikcer.enumerated() {
            let button = UIButton()
            button.frame = CGRect(x: 1, y: offset, width: 200, height: 60)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.addTarget(self, action: #selector(ChatViewController.dropdownMenuSelect(sender:)), for: .touchUpInside)
            button.setTitle(feeling, for: UIControlState())
            button.tag = index

            picker.addSubview(button)

            offset += 60
        }

        view.addSubview(picker)
        view.bringSubview(toFront: picker)
    }

    @objc func dropdownMenuSelect(sender: UIButton) {
        print("sender - \(sender.tag)")
        closePicker()
        if subscription.type == .group {
            if sender.tag == 0 {
                showStarredList()
            }
            if sender.tag == 1 {
                showmentionList()
            }
        } else {
            if sender.tag == 0 {
                showStarredList()
            }
//            if sender.tag == 1 {
//                showmentionList()
//            }
        }

    }

    func showmentionList() {
        guard let userId = AuthManager.currentUser()?.identifier else {
            alert(title: localized("error.socket.default_error_title"), message: "error.socket.default_error_message")
            return
        }

        let data = ListSegueData(title: localized("Mentions Messages"), query: "{\"mentions._id\":{\"$in\":[\"\(userId)\"]}}")
        let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "MessagesListViewController") as? MessagesListViewController
        if let subscription = self.subscription {
            controller?.data.subscription = subscription
            controller?.data.title = data.title
            controller?.data.query = data.query

        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.pushViewController(controller!, animated: true)

    }


    func showStarredList() {
        guard let userId = AuthManager.currentUser()?.identifier else {
            alert(title: localized("error.socket.default_error_title"), message: "error.socket.default_error_message")
            return
        }

        let data = ListSegueData(title: localized("chat.messages.starred.list.title"), query: "{\"starred._id\":{\"$in\":[\"\(userId)\"]}}")
        let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "MessagesListViewController") as? MessagesListViewController
        if let subscription = self.subscription {
            controller?.data.subscription = subscription
            controller?.data.title = data.title
            controller?.data.query = data.query

        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.pushViewController(controller!, animated: true)

    }

    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }

    func openPicker() {
        self.picker.isHidden = false
        if self.subscription.type == .directMessage {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.picker.frame = CGRect(x: self.view.frame.maxX - 200, y: -18, width: 200, height: 100)
                            self.picker.alpha = 1
            })
        }
        if self.subscription.type == .group {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.picker.frame = CGRect(x: self.view.frame.maxX - 200, y: -18, width: 200, height: 160)
                            self.picker.alpha = 1
            })
        }

    }

    func closePicker() {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.picker.frame = CGRect(x: self.view.frame.maxX - 200, y: -18, width: 200, height: 160)
                        self.picker.alpha = 0
        },
                       completion: { finished in
                        self.picker.isHidden = true
        }
        )
    }

    @objc internal func reconnect() {
        
        chatHeaderViewStatus?.activityIndicator.startAnimating()
        chatHeaderViewStatus?.buttonRefresh.isHidden = true

        if !SocketManager.isConnected() {

            SocketManager.reconnect()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !SocketManager.isConnected() {
                self.chatHeaderViewStatus?.activityIndicator.stopAnimating()
                self.chatHeaderViewStatus?.buttonRefresh.isHidden = false
                //SocketManager.addConnectionHandler(token: self.socketHandlerToken, handler: self)
                self.reconnect()
              //  AppManager.reloadApp()
                
               // SocketManager.reconnect()
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let insets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: chatPreviewModeView?.frame.height ?? 0,
            right: 0
            
        )

        collectionView?.contentInset = insets
        collectionView?.scrollIndicatorInsets = insets
     //  self.collectionView?.collectionViewLayout.invalidateLayout()
      //  self.collectionView?.reloadData()
    }
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, segue.identifier == "Channel Info" {
            if let controller = nav.viewControllers.first as? ChannelInfoViewController {
                if let subscription = self.subscription {
                    controller.frommemberlist = "hide"
                    controller.subscription = subscription
                }
            }
        }
    }

    fileprivate func setupTextViewSettings() {
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("_", withTitle: "Italic")
        textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")

        registerPrefixes(forAutoCompletion: ["@", "#"])
    }

    fileprivate func setupTitleView() {
        let view = ChatTitleView.instantiateFromNib()
        self.navigationItem.titleView = view
        chatTitleView = view

        let gesture = UITapGestureRecognizer(target: self, action: #selector(chatTitleViewDidPressed))
        chatTitleView?.addGestureRecognizer(gesture)
    }

    fileprivate func setupScrollToBottomButton() {
        buttonScrollToBottom.layer.cornerRadius = 25
        buttonScrollToBottom.layer.borderColor = UIColor.lightGray.cgColor
        buttonScrollToBottom.layer.borderWidth = 1
    }

    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        return ChatCollectionViewFlowLayout()
    }

    fileprivate func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatLoaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatLoaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)

        collectionView?.register(UINib(
            nibName: "MyChatCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: MyChatCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)

        collectionView?.register(UINib(
            nibName: "ChatChannelHeaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatChannelHeaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatDirectMessageHeaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatDirectMessageHeaderCell.identifier)

        autoCompletionView.register(UINib(
            nibName: "AutocompleteCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: AutocompleteCell.identifier)
    }

    internal func scrollToBottom(_ animated: Bool = false) {
        let boundsHeight = collectionView?.bounds.size.height ?? 0
        let sizeHeight = collectionView?.contentSize.height ?? 0
        let offset = CGPoint(x: 0, y: max(sizeHeight - boundsHeight, 0))
        collectionView?.setContentOffset(offset, animated: animated)
        showButtonScrollToBottom = false
    }

    // MARK: SlackTextViewController

    override func canPressRightButton() -> Bool {
        return SocketManager.isConnected()
    }

    override func didPressRightButton(_ sender: Any?) {
        sendMessage()
    }

    override func didPressLeftButton(_ sender: Any?) {
        buttonUploadDidPressed()
    }

    override func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        sendMessage()
    }

    override func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom(true)
    }

    override func textViewDidChange(_ textView: UITextView) {
        if textView.text?.isEmpty ?? true {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
        } else {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: true)
        }
    }

    // MARK: Message
    fileprivate func sendMessage() {
        guard let messageText = textView.text, messageText.characters.count > 0 else { return }

        let replyString = self.replyString
        stopReplying()

        self.scrollToBottom()
        rightButton.isEnabled = false

        var message: Message?
        Realm.executeOnMainThread({ (realm) in
            message = Message()
            message?.internalType = ""
            message?.createdAt = Date.serverDate
            message?.text = "\(messageText)\(replyString)"
            message?.subscription = self.subscription
            message?.identifier = String.random(18)
            message?.temporary = true
            message?.user = AuthManager.currentUser()

            if let message = message {
                realm.add(message)
            }
        })

        if let message = message {
            textView.text = ""
            rightButton.isEnabled = true
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)

            SubscriptionManager.sendTextMessage(message) { response in
                Realm.executeOnMainThread({ (realm) in
                    message.temporary = false
                    message.map(response.result["result"], realm: realm)
                    realm.add(message, update: true)

                    MessageTextCacheManager.shared.update(for: message)
                })
            }
        }
    }

    fileprivate func chatLogIsAtBottom() -> Bool {
        guard let collectionView = collectionView else { return false }

        let height = collectionView.bounds.height
        let bottomInset = collectionView.contentInset.bottom
        let scrollContentSizeHeight = collectionView.contentSize.height
        let verticalOffsetForBottom = scrollContentSizeHeight + bottomInset - height

        return collectionView.contentOffset.y >= (verticalOffsetForBottom - 1)
    }

    // MARK: Subscription

    fileprivate func markAsRead() {
        SubscriptionManager.markAsRead(subscription) { _ in
            // Nothing, for now
        }
    }

    internal func unsubscribe(for subscription: Subscription) {
        SocketManager.unsubscribe(eventName: subscription.rid)
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
    }

    internal func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.invalidate()
        }

        title = subscription?.displayName()
        chatTitleView?.subscription = subscription
        textView.resignFirstResponder()

        collectionView?.performBatchUpdates({
            let indexPaths = self.dataController.clear()
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { _ in
            CATransaction.commit()

            if self.closeSidebarAfterSubscriptionUpdate {
                MainChatViewController.closeSideMenuIfNeeded()
                self.closeSidebarAfterSubscriptionUpdate = false
                //self.collectionView?.reloadData()
            }
        })

        if self.subscription.isValid() {
            self.updateSubscriptionMessages()
        } else {
            self.subscription.fetchRoomIdentifier({ [weak self] response in
                self?.subscription = response
            })
        }

        if subscription.isJoined() {
            setTextInputbarHidden(false, animated: false)
            chatPreviewModeView?.removeFromSuperview()
        } else {
            setTextInputbarHidden(true, animated: false)
            showChatPreviewModeView()
        }

        if subscription.roomReadOnly && subscription.roomOwner != AuthManager.currentUser() {
            blockMessageSending(reason: localized("chat.read_only"))
        } else {
            allowMessageSending()
        }
        print("subsb type find-\(subscription.type)")
        if subscription.type == .directMessage {
                       self.arrPikcer = ["Star Messages"]
                           // ["title": "Mention Messages", "color": "#4870b7"],
                            //  ["title": "File Document", "color": "#45a85a"]

                    }else  if subscription.type == .group  {
             self.arrPikcer = ["Star Messages","Mention Messages"]
                    }
        //collectionView?.reloadData()
    }

    internal func updateSubscriptionMessages() {
        messagesQuery = subscription.fetchMessagesQueryResults()

       activityIndicator.startAnimating()

        dataController.loadedAllMessages = false
        isRequestingHistory = false
        updateMessagesQueryNotificationBlock()
        loadMoreMessagesFrom(date: nil)

        MessageManager.changes(subscription)
        registerTypingEvent()

    }

    fileprivate func registerTypingEvent() {
        typingIndicatorView?.interval = 0

        SubscriptionManager.subscribeTypingEvent(subscription) { [weak self] username, flag in
            guard let username = username else { return }

            let isAtBottom = self?.chatLogIsAtBottom()

            if flag {
                self?.typingIndicatorView?.insertUsername(username)
            } else {
                self?.typingIndicatorView?.removeUsername(username)
            }

            if let isAtBottom = isAtBottom,
                isAtBottom == true {
                self?.scrollToBottom(true)
            }
        }
    }

    fileprivate func updateMessagesQueryNotificationBlock() {
        messagesToken?.invalidate()
        messagesToken = messagesQuery.observe { [unowned self] changes in
            guard case .update(_, _, let insertions, let modifications) = changes else {
                return
            }

            if insertions.count > 0 {
                var newMessages: [Message] = []
                for insertion in insertions {
                    let newMessage = Message(value: self.messagesQuery[insertion])
                    newMessages.append(newMessage)
                }

                self.messages.append(contentsOf: newMessages)
                self.appendMessages(messages: newMessages, completion: {
                    self.markAsRead()
                })
            }

            if modifications.count == 0 {
                return
            }

            let messagesCount = self.messagesQuery.count
            var indexPathModifications: [Int] = []

            for modified in modifications {
                if messagesCount < modified + 1 {
                    continue
                }

                let message = Message(value: self.messagesQuery[modified])
                let index = self.dataController.update(message)
                if index >= 0 && !indexPathModifications.contains(index) {
                    indexPathModifications.append(index)
                }
            }

            if indexPathModifications.count > 0 {
                DispatchQueue.main.async {
                    let isAtBottom = self.chatLogIsAtBottom()
                    UIView.performWithoutAnimation {
                        self.collectionView?.performBatchUpdates({
                            self.collectionView?.reloadItems(at: indexPathModifications.map {
                                IndexPath(row: $0, section: 0)
                                }
                            )
                        }, completion: { _ in
                            if isAtBottom {
                                self.scrollToBottom()
                                DispatchQueue.main.async {
                                    self.collectionView?.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    func loadHistoryFromRemote(date: Date?) {
        let tempSubscription = Subscription(value: self.subscription)

        MessageManager.getHistory(tempSubscription, lastMessageDate: date) { [weak self] messages in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isRequestingHistory = false
                self?.loadMoreMessagesFrom(date: date, loadRemoteHistory: false)

                if messages.count == 0 {
                    self?.dataController.loadedAllMessages = true

                    self?.collectionView?.performBatchUpdates({
                        if let (indexPaths, removedIndexPaths) = self?.dataController.insert([]) {
                            self?.collectionView?.insertItems(at: indexPaths)
                            self?.collectionView?.deleteItems(at: removedIndexPaths)
                        }
                    }, completion: { _ in
                        //self?.scrollToBottom() // neeed to change in future .
                    })
                } else {
                    self?.dataController.loadedAllMessages = false
                }
            }
        }
    }

    fileprivate func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
        if isRequestingHistory || dataController.loadedAllMessages {
            return
        }

        isRequestingHistory = true

        let newMessages = subscription.fetchMessages(lastMessageDate: date).map({ Message(value: $0) })
        if newMessages.count > 0 {
            messages.append(contentsOf: newMessages)
            appendMessages(messages: newMessages, completion: { [weak self] in
                self?.activityIndicator.stopAnimating()

                if date == nil {
                    self?.scrollToBottom()
                }

                if SocketManager.isConnected() {
                    if !loadRemoteHistory {
                        self?.isRequestingHistory = false
                    } else {
                        self?.loadHistoryFromRemote(date: date)
                    }
                } else {
                    self?.isRequestingHistory = false
                }
            })
        } else {
            if SocketManager.isConnected() {
                if loadRemoteHistory {
                    loadHistoryFromRemote(date: date)
                } else {
                    isRequestingHistory = false
                }
            } else {
                isRequestingHistory = false
            }
        }
        //collectionView?.reloadData()
    }

    fileprivate func appendMessages(messages: [Message], completion: VoidCompletion?) {
        guard let collectionView = self.collectionView else { return }
        guard !isAppendingMessages else {
            Log.debug("[APPEND MESSAGES] Blocked trying to append \(messages.count) messages")

            // This message can be called many times during the app execution and we need
            // to call them one per time, to avoid adding the same message multiple times
            // to the list. Also, we keep the subscription identifier in order to make sure
            // we're updating the same subscription, because this view controller is reused
            // for all the chats.
            let oldSubscriptionIdentifier = self.subscription.identifier
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard oldSubscriptionIdentifier == self?.subscription.identifier else { return }
                self?.appendMessages(messages: messages, completion: completion)
            })

            return
        }

        isAppendingMessages = true

        var tempMessages: [Message] = []
        for message in messages {
            tempMessages.append(Message(value: message))
        }

        DispatchQueue.global(qos: .background).async {
            var objs: [ChatData] = []
            var newMessages: [Message] = []

            // Do not add duplicated messages
            for message in tempMessages {
                var insert = true

                for obj in self.dataController.data
                    where message.identifier == obj.message?.identifier {
                        insert = false
                }

                if insert {
                    newMessages.append(message)
                }
            }

            // Normalize data into ChatData object
            for message in newMessages {
                guard let createdAt = message.createdAt else { continue }
                var obj = ChatData(type: .message, timestamp: createdAt)
                obj.message = message
                objs.append(obj)
            }

            // No new data? Don't update it then
            if objs.count == 0 {
                DispatchQueue.main.async {
                    self.isAppendingMessages = false
                    completion?()
                }

                return
            }

            DispatchQueue.main.async {
                collectionView.performBatchUpdates({
                    let (indexPaths, removedIndexPaths) = self.dataController.insert(objs)
                    collectionView.insertItems(at: indexPaths)
                    collectionView.deleteItems(at: removedIndexPaths)
                    collectionView.superview?.setNeedsLayout()
                }, completion: { _ in
                    self.isAppendingMessages = false
                    completion?()
                   // collectionView.reloadData()

                })
            }
        }
    }

    fileprivate func blockMessageSending(reason: String) {
        textInputbar.textView.placeholder = reason
        textInputbar.backgroundColor = .white
        textInputbar.isUserInteractionEnabled = false
        leftButton.isEnabled = false
        rightButton.isEnabled = false
    }

    fileprivate func allowMessageSending() {
        textInputbar.textView.placeholder = ""
        textInputbar.backgroundColor = .backgroundWhite
        textInputbar.isUserInteractionEnabled = true
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }

    fileprivate func showChatPreviewModeView() {
        chatPreviewModeView?.removeFromSuperview()

        if let previewView = ChatPreviewModeView.instantiateFromNib() {
            previewView.delegate = self
            previewView.subscription = subscription
            previewView.frame = CGRect(x: 0, y: view.frame.height - previewView.frame.height, width: view.frame.width, height: previewView.frame.height)
            view.addSubview(previewView)
            chatPreviewModeView = previewView
        }
    }

    fileprivate func isContentBiggerThanContainerHeight() -> Bool {
        if let contentHeight = self.collectionView?.contentSize.height {
            if let collectionViewHeight = self.collectionView?.frame.height {
                if contentHeight < collectionViewHeight {
                    return false
                }
            }
        }

        return true
    }

    // MARK: IBAction

    @objc func chatTitleViewDidPressed(_ sender: AnyObject) {
        print("typeSub-\(subscription.type)")
        if subscription.type == .group {
            let loginVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "MembersListViewController") as? MembersListViewController
            loginVC?.data.subscription = self.subscription
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            self.navigationController?.pushViewController(loginVC!, animated: true)
        } else if subscription.type == .channel {
            let loginVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "MembersListViewController") as? MembersListViewController
            loginVC?.data.subscription = self.subscription
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            self.navigationController?.pushViewController(loginVC!, animated: true)
        } else{
             performSegue(withIdentifier: "Channel Info", sender: sender)
        }
    }

    @IBAction func buttonScrollToBottomPressed(_ sender: UIButton) {
        scrollToBottom(true)
    }
}
//let textbubbleview: UIView = {
//    let view  = UIView()
//    view.backgroundColor = UIColor.red
//    view.layer.cornerRadius = 15
//    view.layer.masksToBounds = true
//    return view
//}()
// MARK: UICollectionViewDataSource

extension ChatViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < 4 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
      //  view.updateConstraints()
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataController.data.count > indexPath.row else { return UICollectionViewCell() }
        guard let obj = dataController.itemAt(indexPath) else { return UICollectionViewCell() }

        if obj.type == .message {
            return cellForMessage(obj, at: indexPath)
        }

        if obj.type == .daySeparator {
            return cellForDaySeparator(obj, at: indexPath)
        }

        if obj.type == .loader {
            return cellForLoader(obj, at: indexPath)
        }

        if obj.type == .header {
            if subscription.type == .directMessage {
                return cellForDMHeader(obj, at: indexPath)
            } else {
                return cellForChannelHeader(obj, at: indexPath)
            }
        }

        return UICollectionViewCell()
    }

    func getStringSizeForFont(font: UIFont, myText: String) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = (myText as NSString).size(withAttributes: fontAttributes)

        return size

    }
    // MARK: Cells
    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {

        print("indepathrow no - \(indexPath.row)")
        print("otheruserid\(obj.message?.user?.username)")
        print("loginuser\(AuthManager.currentUser()?.username)")
        if  obj.message?.user?.username == AuthManager.currentUser()?.username {
            guard let cell = collectionView?.dequeueReusableCell(
                withReuseIdentifier: MyChatCell.identifier,
                for: indexPath
                ) as? MyChatCell else {
                    return UICollectionViewCell()
            }
            cell.delegate = self as? MyChatCellProtocol
            
            if let message = obj.message {
                cell.message = message
            }
          //  cell.backgroundColor = UIColor.red
            cell.sequential = dataController.hasSequentialMessageAt(indexPath)
            if let message = obj.message {
//                let sequential = dataController.hasSequentialMessageAt(indexPath)
//                _ = MyChatCell.cellMediaHeightFor(message: message, sequential: sequential)
              //  let boundingSize = CGSize(width: 300, height: 10000000)
              //  var itemTextSize: CGSize = message.text.size(with: UIFont.systemFont(ofSize: 14), constrainedTo: boundingSize, lineBreakMode: .byWordWrapping)
                let contentSize = cell.labelText.sizeThatFits(cell.labelText.bounds.size)
                let widthrect = contentSize.width
              //  _ = cell.bubbleleadingconstrainsts.constant
                _ = cell.lbltextleadingconstrainsts.constant
               // cell.labelText.backgroundColor = UIColor.gray
                _ = collectionView?.bounds.size.width
               let size = cell.labelDate.frame.minX
                if obj.message?.actionL.count != 0 {
                    let sequential = dataController.hasSequentialMessageAt(indexPath)
                    let height = MyChatCell.cellMediaHeightFor(message: message, sequential: sequential)
                    cell.bubbleImage.frame = CGRect(x: cell.messageContainerView.frame.size.width - cell.labelDate.frame.origin.x - 35, y: -3, width: cell.labelDate.frame.minX + 35, height: height + 30)
                    self.view.layoutIfNeeded()
                }
                else {
                    if obj.message?.attachments.count == 0 && obj.message?.urls.count == 0 {
                        cell.bottommediaviewConstrains.constant = 10
                        if widthrect + 10 > size + 5 {
                            //lbltextleadingconstrainsts
                            let sequential = dataController.hasSequentialMessageAt(indexPath)
                            let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                            // cell.bubbleleadingconstrainsts.constant = 0
                            cell.bubbleImage.frame = CGRect(x: cell.messageContainerView.frame.size.width - widthrect - 30, y: -3, width: widthrect + 30, height: height + 20)
                            self.view.layoutIfNeeded()
                            // cell.layoutIfNeeded()
                            //cell.lbltextleadingconstrainsts.constant = cell.messageContainerView.frame.size.width - rect.width - 8

                        } else {
                            let sequential = dataController.hasSequentialMessageAt(indexPath)
                            let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                            cell.bubbleImage.frame = CGRect(x: cell.messageContainerView.frame.size.width - cell.labelDate.frame.origin.x - 45, y: -3, width: cell.labelDate.frame.minX + 45, height: height + 20)
                            self.view.layoutIfNeeded()
                            // cell.bubbleImage.layoutIfNeeded()
                            //   cell.lbltextleadingconstrainsts.constant = size - 15
                        }
                    } else {
                        //  cell.bottommediaviewConstrains.constant = 30
                        for attachment in message.attachments {
                            let type = attachment.type
                            if type == .image {
                                cell.bottommediaviewConstrains.constant = 30
                            }
                            if type == .url {
                                cell.bottommediaviewConstrains.constant = 10
                            }
                        }
                        let sequential = dataController.hasSequentialMessageAt(indexPath)
                        let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                        cell.bubbleImage.frame = CGRect(x: 0, y: -3, width: cell.messageContainerView.frame.size.width + 2, height: (self.collectionView?.collectionViewLayout.collectionViewContentSize.height)! - 10)
                        // cell.bubbleImage.layoutIfNeeded()
                        cell.mediaViews.layoutIfNeeded()
                        //  cell.lbltextleadingconstrainsts.constant = 0
                    }

                }

                //cell.bubbleImage.autoresizingMask = .flexibleLeftMargin
              //  cell.contentView.layoutIfNeeded()
                 //cell.hieghtView.constant = height
            }
             cell.bubbleImage.image = UIImage(named: "bubbleMine")?.stretchableImage(withLeftCapWidth: 8, topCapHeight: 30)
            return cell
        } else {
            guard let cell = collectionView?.dequeueReusableCell(
                withReuseIdentifier: ChatMessageCell.identifier,
                for: indexPath
                ) as? ChatMessageCell else {
                    return UICollectionViewCell()
            }
            // cell.labelText.text
            cell.delegate = self as? ChatMessageCellProtocol
            if let message = obj.message {
                cell.message = message
                if obj.message?.actionL.count != 0 {
                    let contentSize = cell.labelText.sizeThatFits(cell.labelDate.bounds.size)
                    let higntcons = contentSize.width
                    cell.bubbleWidthImage.constant = CGFloat(higntcons + (cell.labelDate.frame.maxX - higntcons) + 10)
                    cell.bubbleImage.layoutIfNeeded()

                }
                else {
                    
                ////
                if message.attachments.count == 0 && message.urls.count == 0 {
                    let contentSize = cell.labelText.sizeThatFits(cell.labelText.bounds.size)
                    let higntcons = contentSize.width
                    print("max x date - \(cell.labelDate.frame.maxX)")
                    print("max x higntcons - \(cell.labelDate.frame.maxX)")
                    if higntcons + 20 <= cell.labelDate.frame.maxX + 10{
                        let contentSize = cell.labelDate.sizeThatFits(cell.labelDate.bounds.size)
                        let labelUsernameSize = cell.labelUsername.sizeThatFits(cell.labelUsername.bounds.size)
                       if subscription.type == .group ||  subscription.type == .channel {
                        cell.bubbleWidthImage.constant = CGFloat(cell.contentView.frame.size.width - 30)
                        cell.bubbleImage.layoutIfNeeded()
                        } else {
                            cell.bubbleWidthImage.constant = CGFloat(higntcons + (cell.labelDate.frame.maxX - higntcons) + 10)
                            cell.bubbleImage.layoutIfNeeded()
                        }
                    } else {
                        if subscription.type == .group ||  subscription.type == .channel {
                            cell.bubbleWidthImage.constant = CGFloat(cell.contentView.frame.size.width - 30)
                            cell.bubbleImage.layoutIfNeeded()
                        } else {
                            cell.bubbleWidthImage.constant = CGFloat(higntcons + 20)
                            cell.bubbleImage.layoutIfNeeded()
                        }
                }
                } else {
                    if message.urls.count != 0 {
                        cell.bubbleWidthImage.constant = CGFloat(cell.contentView.frame.size.width - 30)
                    } else {
                        cell.bubbleWidthImage.constant = CGFloat(cell.contentView.frame.size.width - 30)
                    }
                      cell.bubbleImage.layoutIfNeeded()
                }
            }
            }
              let sequential = dataController.hasSequentialMessageAt(indexPath)
             cell.bubbleImage.image = UIImage(named: "Chatbox")?.stretchableImage(withLeftCapWidth: 21, topCapHeight: 30)
          //  cell.layoutIfNeeded()
           // cell.labelText.isScrollEnabled = false
            return cell
        }
    }

    func textViewDisplaySize(for text: String, withFront fontName: String) -> CGSize {
       // let screen: CGSize = UIScreen.main.applicationFrame.size
        let size = CGSize(width: 250, height: 1000)
        // This is where the magic happens.
        let rect: CGRect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: fontName], context: nil)
        return rect.size
    }

    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageDaySeparator.identifier,
            for: indexPath
        ) as? ChatMessageDaySeparator else {
                return UICollectionViewCell()
        }
        cell.labelTitle.text = obj.timestamp.formatted("MMM dd, YYYY")
        return cell
    }

    func cellForChannelHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatChannelHeaderCell.identifier,
            for: indexPath
        ) as? ChatChannelHeaderCell else {
            return UICollectionViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForDMHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatDirectMessageHeaderCell.identifier,
            for: indexPath
        ) as? ChatDirectMessageHeaderCell else {
            return UICollectionViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForLoader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatLoaderCell.identifier,
            for: indexPath
        ) as? ChatLoaderCell else {
            return UICollectionViewCell()
        }

        return cell
    }

}

// MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.bounds.size.width

        if let obj = dataController.itemAt(indexPath) {
            if obj.type == .header {
                if subscription.type == .directMessage {
                    return CGSize(width: fullWidth, height: ChatDirectMessageHeaderCell.minimumHeight)
                } else {
                    return CGSize(width: fullWidth, height: ChatChannelHeaderCell.minimumHeight)
                }
            }

            if obj.type == .loader {
                return CGSize(width: fullWidth, height: ChatLoaderCell.minimumHeight)
            }

            if obj.type == .daySeparator {
                return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
            }

            if let message = obj.message {
//                    let sequential = dataController.hasSequentialMessageAt(indexPath)
//                    let height = MyChatCell.cellMediaHeightFor(message: message, sequential: sequential)
                if  obj.message?.user?.username == AuthManager.currentUser()?.username {
                    let sequential = dataController.hasSequentialMessageAt(indexPath)
                    let height = MyChatCell.cellMediaHeightFor(message: message, sequential: sequential)
                    if  obj.message?.attachments.count == 0 && obj.message?.urls.count == 0 {
                        return CGSize(width: fullWidth, height: height + 30)
                    } else {
                        return CGSize(width: fullWidth, height: height + 30)
                    }
                }
                else{
                    let sequential = dataController.hasSequentialMessageAt(indexPath)
                    let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                    if  obj.message?.attachments.count == 0 && obj.message?.urls.count == 0 {
                        return CGSize(width: fullWidth, height: height + 20)
                    } else {
                        return CGSize(width: fullWidth, height: height + 18)
                    }
                    // let starWidth = (message.text.widthOfString(usingFont: UIFont.systemFont(ofSize: 14))) + 1

                }

            }
        }

        return CGSize(width: fullWidth, height: 40)
    }
}

// MARK: UIScrollViewDelegate



extension ChatViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if scrollView.contentOffset.y < -10 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }

        showButtonScrollToBottom = !chatLogIsAtBottom()
    }
}

extension String {


}

// MARK: ChatPreviewModeViewProtocol

extension ChatViewController: ChatPreviewModeViewProtocol {

    func userDidJoinedSubscription() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }

        Realm.executeOnMainThread({ _ in
            subscription.auth = auth
        })

        self.subscription = subscription
    }

}



