//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SZMentionsSwift
var kTermTag = "termTag"
protocol ChatMessageCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol, ChatMessageImageViewProtocol, ChatMessageTextViewProtocol  {
    func openURL(url: URL)
    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
}


final class ChatMessageCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatMessageCell"


    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol?
    var message: Message! {
        didSet {
            updateMessage()
        }
    }
    @IBOutlet weak var bubbletrailingconstrains: NSLayoutConstraint!

    @IBOutlet weak var lbltexttrailingconstraints: NSLayoutConstraint!

    @IBOutlet weak var messagecontenviewTrailingconstraints: NSLayoutConstraint!
    
    @IBOutlet weak var lblDateTrailingConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var hieghtView: NSLayoutConstraint!
    @IBOutlet weak var bubbleImage: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!

    @IBOutlet weak var bottommediaviewConstraints: NSLayoutConstraint!


    @IBOutlet weak var backLabelChatMesaage: UILabel!
    
    @IBOutlet weak var backLBLConstraints: NSLayoutConstraint!

    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    weak var avatarView: AvatarView! {
        didSet {
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: UITextView! {
        didSet {
            labelText.textContainerInset = .zero
            labelText.delegate = self
        }
    }



    @IBOutlet weak var mediaViews: UIStackView!
    @IBOutlet weak var mediaViewsHeightConstraint: NSLayoutConstraint!

    static func cellMediaHeightFor(message: Message, sequential: Bool = true) -> CGFloat {
        let fullWidth = UIScreen.main.bounds.size.width
        let attributedString = MessageTextCacheManager.shared.message(for: message)
        let height = attributedString?.heightForView(withWidth: fullWidth - 62)
        var total: CGFloat = 0
//        let starWidth = (message.text.widthOfString(usingFont: UIFont.systemFont(ofSize: 14))) + 16
//        let starhieght = (message.text.heightOfString(usingFont: UIFont.systemFont(ofSize: 14))) + 16
        if attributedString?.string == "" {
            total = 0
        } else {
            total = height! + 30
        }

        for url in message.urls {
            guard url.isValid() else { continue }
            total += ChatMessageURLView.defaultHeight
        }
        for link in message.actionL {
            print("check link is \(link.label)-\(link.params)")
            guard link.params != nil else { continue }
            total += LeftActionlinkView.defaultHeight
        }


        for attachment in message.attachments {
            let type = attachment.type

            if type == .textAttachment {
                total += ChatMessageTextView.heightFor(collapsed: attachment.collapsed, withText: attachment.text)
            }

            if type == .image {
                total += ChatMessageImageView.defaultHeight
            }

            if type == .video {
                total += ChatMessageVideoView.defaultHeight
            }

            if type == .audio {
                total += ChatMessageAudioView.defaultHeight
            }
        }

        return total
    }

    @IBOutlet weak var bubbleWidthImage: NSLayoutConstraint!

    // MARK: Sequential
    @IBOutlet weak var labelUsernameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerHeightConstraint: NSLayoutConstraint!

    var sequential: Bool = false {
        didSet {
            avatarContainerHeightConstraint.constant = sequential ? 0 : 35
            labelUsernameHeightConstraint.constant = sequential ? 0 : 21
            labelDateHeightConstraint.constant = sequential ? 0 : 21
        }
    }

    override func prepareForReuse() {
        labelUsername.text = ""
        labelText.text = ""
        labelDate.text = ""
        sequential = false

//        let attributedString = MessageTextCacheManager.shared.message(for: message)
//        let width = attributedString?.widthForView(withWidth: 308)
//        let height = attributedString?.heightForView(withWidth: 308)
//        let currentLabelSize = CGSize(width: bubbleImage.frame.origin.x, height: bubbleImage.frame.origin.y)
//        bubbleImage.frame = CGRect(x: currentLabelSize.width, y: currentLabelSize.height, width: 150, height: height ?? 0.0)
        for view in mediaViews.arrangedSubviews {
            view.removeFromSuperview()
        }

    }

    func setUI() -> CGFloat {
        let fullWidth = UIScreen.main.bounds.size.width
        let attributedString = MessageTextCacheManager.shared.message(for: message)
        let width = attributedString?.widthForView(withWidth: fullWidth - 40)
        let total = (width ?? 0)
        if total <= labelDate.frame.origin.x + labelDate.frame.size.width {
            return labelDate.frame.origin.x + labelDate.frame.size.width + 20
        }
        return total + 25
    }


    func insertGesturesIfNeeded() {
        if longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.5
            gesture.delegate = self
            addGestureRecognizer(gesture)

            longPressGesture = gesture
        }

        if usernameTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            labelUsername.addGestureRecognizer(gesture)

            usernameTapGesture = gesture
        }

        if avatarTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            avatarView.addGestureRecognizer(gesture)

            avatarTapGesture = gesture
        }
        
    }

    func insertURLs() -> CGFloat {
        var addedHeight = CGFloat(0)
        message.urls.forEach { url in
            guard url.isValid() else { return }
            if let view = ChatMessageURLView.instantiateFromNib() {
                view.url = url
                view.delegate = delegate

                mediaViews.addArrangedSubview(view)
                addedHeight += ChatMessageURLView.defaultHeight
            }
        }
        return addedHeight
    }

    func insertvideolink() -> CGFloat {
        var addedHeight = CGFloat(0)// guard url.isValid() else { return }
        message.actionL.forEach { obj in
            if let view = LeftActionlinkView.instantiateFromNib() {
                print("obj.params 1-\(obj.params ?? "")")
                view.stringParma = obj.params
                // view.btnClicktoJoin.addTarget(self, action: #selector(openvideo(id:)), for: UIControlEvents.touchUpInside)
                mediaViews.addArrangedSubview(view)
                addedHeight += LeftActionlinkView.defaultHeight
            }
        }
        return addedHeight
    }


    func insertAttachments() {
        var mediaViewHeight = CGFloat(0)

        mediaViewHeight += insertURLs()
         mediaViewHeight += insertvideolink()
        message.attachments.forEach { attachment in
            let type = attachment.type

            switch type {
            case .textAttachment:
                if let view = ChatMessageTextView.instantiateFromNib() {
                    view.backgroundColor = UIColor(rgb: 0xECECEC, alphaVal: 1)
                    view.layer.cornerRadius = 4.0
                    view.layer.masksToBounds = true
                    view.viewModel = ChatMessageTextViewModel(withAttachment: attachment)
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageTextView.heightFor(collapsed: attachment.collapsed, withText: attachment.text)
                }

            case .image:
                if let view = ChatMessageImageView.instantiateFromNib() {
                    view.attachment = attachment
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageImageView.defaultHeight
                }

            case .video:
                if let view = ChatMessageVideoView.instantiateFromNib() {
                    view.attachment = attachment
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageVideoView.defaultHeight
                }

            case .audio:
                if let view = ChatMessageAudioView.instantiateFromNib() {
                    view.attachment = attachment
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageAudioView.defaultHeight
                }

            default:
                return
            }
        }

        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
    }

    fileprivate func updateMessageHeader() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if let createdAt = message.createdAt {
            labelDate.text = formatter.string(from: createdAt)
        }

        avatarView.imageURL = URL(string: message.avatar)
        avatarView.user = message.user

        if message.alias.characters.count > 0 {
            labelUsername.text = message.alias
        } else {
            labelUsername.text = message.newname.capitalizingFirstLetter()
        }
        //labelUsername.sizeToFit()
        //labelDate.sizeToFit()
    }

    fileprivate func updateMessageContent() {


        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        self.labelText.addGestureRecognizer(gesture)

        longPressGesture = gesture
        let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0)]


        let string:NSMutableAttributedString = NSMutableAttributedString(string: message.text,attributes: attrs)
        // let stringWithAttribute  = NSAttributedString(string: message.text,attributes: myAttribute)
        let words:[String] = message.text.components(separatedBy:" ")
        var w = ""

        for item in message.mentions {
            for var word in words {
                if word == ("@\(item.username ?? "")") {
                    if word != "" {
                        let realName = item.realName ?? ""
                        let username = word
                        let range:NSRange = (string.string as NSString).range(of: word)
                        //  string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
                        string.addAttribute(NSAttributedStringKey.link, value: "hash:\(word)", range: range)
                        w = word.replacingOccurrences(of: username, with: "@\(realName)")
                        w = w.replacingOccurrences(of:"@", with: "@")
                        string.replaceCharacters(in: range, with: w)
                    }

                }
                if word == ("@\(item.realName ?? "")") {
                    if word != "" {
                        let range:NSRange = (string.string as NSString).range(of: word)
                        string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
                        w = word.replacingOccurrences(of: "@", with: "@")
                        w = w.replacingOccurrences(of:"@", with: "@")
                        string.replaceCharacters(in: range, with: w)
                    }

                }

            }
        }


        labelText.attributedText = string
       // labelText.textAlignment = .right

//        if let text = MessageTextCacheManager.shared.message(for: message) {
////            if message.temporary {
////                text.setFontColor(MessageTextFontAttributes.systemFontColor)
////            }
//
//            print("isseqentials-\(message.type.sequential),\(text.string)")
////            message.mentions.forEach {
////                if let name = $0.username {
////                    let auth: Auth? = AuthManager.isAuthenticated()
////                    let newsubscription = auth?.subscriptions.filter("name = %@", name).first
////                    let newString = text.string.replacingOccurrences(of: name, with: "\(newsubscription?.fname ?? "")", options: .literal, range: nil)
////                    print("newstring\(newString)")
////                }
////            }
//           // let newString = text.string.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
//
//          // labelText.attributedText = text
//            labelText.attributedText = resolveHashTags(text: text.string)
//            labelText.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.link]
//        }

//        if message?.attachments.count == 0 && message?.urls.count == 0 {
//            textViewDynamicallyIncreaseSize()
//        } else {
//            DispatchQueue.main.async {
//                if self.message?.urls.count != 0 {
//                    self.bubbleWidthImage.constant = self.contentView.frame.size.width - 30
//                } else {
//                    self.bubbleWidthImage.constant = self.contentView.frame.size.width - 30
//                }
//                //  self.bubbleImage.layoutIfNeeded()
//            }
//        }
    }

    func textViewDynamicallyIncreaseSize() {
        let contentSize = self.labelText.sizeThatFits(self.labelText.bounds.size)
        let higntcons = contentSize.width
        if higntcons + 20 <= labelDate.frame.maxX {
             DispatchQueue.main.async {
                let contentSize = self.labelDate.sizeThatFits(self.labelDate.bounds.size)
                let labelUsernameSize = self.labelUsername.sizeThatFits(self.labelUsername.bounds.size)

                self.bubbleWidthImage.constant = higntcons + (self.labelDate.frame.maxX - higntcons) + 10
            }

        } else {
            DispatchQueue.main.async {
                self.bubbleWidthImage.constant = higntcons + 20
            }

        }

    }

    func resolveHashTags(text : String) -> NSAttributedString{
        var length : Int = 0
        let text:String = text
        let words:[String] = text.separate(withChar: " ")
        let hashtagWords = words.flatMap({$0.separate(withChar: "@")})
        let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0)]
        let attrString = NSMutableAttributedString(string: text, attributes:attrs)
        for word in hashtagWords {
            if word.hasPrefix("@") {
                
                let matchRange:NSRange = NSMakeRange(length, word.characters.count)
                let stringifiedWord:String = word

                attrString.addAttribute(NSAttributedStringKey.link, value: "hash:\(stringifiedWord)", range: matchRange)
            }
            length += word.characters.count
        }
        return attrString
    }

    func callBack(string: String , wordtype : WordType) {
        print("Recevied :",string)
    }

    fileprivate func updateMessage() {
        guard delegate != nil else { return }

       // updateMessageHeader()
        updateMessageContent()

        if !sequential {
            updateMessageHeader()
        }
        insertGesturesIfNeeded()
        insertAttachments()
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        delegate?.handleLongPressMessageCell(message, view: contentView, recognizer: recognizer)
    }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        delegate?.handleUsernameTapMessageCell(message, view: contentView, recognizer: recognizer)
    }

}

extension ChatMessageCell: UIGestureRecognizerDelegate {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.delete(_:)) || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:)) || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:)) || action == #selector(UIResponderStandardEditActions.toggleBoldface(_:)) || action == #selector(UIResponderStandardEditActions.toggleItalics(_:)) || action == #selector(UIResponderStandardEditActions.toggleUnderline(_:)) {
//            return false
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}




extension String {

    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst()).lowercased()
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    public func separate(withChar char : String) -> [String]{
        var word : String = ""
        var words : [String] = [String]()
        for chararacter in self.characters {
            if String(chararacter) == char && word != "" {
                words.append(word)
                word = char
            }else {
                word += String(chararacter)
            }
        }
        words.append(word)
        return words
    }
}
extension ChatMessageCell: UITextViewDelegate {
    func cancelClicked(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction != .invokeDefaultAction {
            return false
        }
        let stringurl = "\(url)".components(separatedBy:":").last
        print("url check\(url)")
        if (stringurl?.hasPrefix("@"))! {
            for item in message.mentions {
                if stringurl == "@\(item.username)" {
                    print("match usernmae congo")
                }
            }
            if (stringurl != nil) {


                if let loginVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChannelInfoViewController") as? ChannelInfoViewController {
                    loginVC.frommemberlist = "chatcell"
                    loginVC.nameofuser = (stringurl?.components(separatedBy:"@").last)!
                    let navigationController = BaseNavigationController(rootViewController: loginVC)
                    let b = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: Selector(("cancelClicked:")))
                    navigationController.navigationItem.backBarButtonItem = b
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.window?.rootViewController?.present(navigationController, animated: true, completion: {
                        //  textView.text.insert("@", at: textView.text.startIndex)
                        self.updateMessageContent()
                    })

                    print("link to print")

                }


            }


        }
        let words:[NSString] = textView.text.components(separatedBy: " ") as [NSString]
        for var word in words {


        }
        return true
    }


    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {


        if URL.scheme == "http" || URL.scheme == "https" {
            delegate?.openURL(url: URL)
            return false
        }

        return true
    }

}

extension UITextView {

    override open func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            do {
                let array = try gestureRecognizer.value(forKey: "_targets") as? NSMutableArray
                let targetAndAction = array?.firstObject
                let actions = ["action=oneFingerForcePan:",
                               "action=_handleRevealGesture:",
                               "action=loupeGesture:",
                               "action=longDelayRecognizer:"]

                for action in actions {
                    print("targetAndAction.debugDescription: \(targetAndAction.debugDescription)")
                    if targetAndAction.debugDescription.contains(action) {
                        gestureRecognizer.isEnabled = false
                    }
                }

            } catch let exception {
                print("TXT_VIEW EXCEPTION : \(exception)")
            }
            defer {
                super.addGestureRecognizer(gestureRecognizer)
            }
        }
    }

}
