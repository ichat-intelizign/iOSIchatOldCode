//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SZMentionsSwift
//var kTermTag = "termTag"
protocol MyChatCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol, ChatMessageImageViewProtocol, ChatMessageTextViewProtocol,UITextViewDelegate  {
    func openURL(url: URL)
    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
}


final class MyChatCell: UICollectionViewCell {
    
    static let minimumHeight = CGFloat(55)
    static let identifier = "MyChatCell"
    
    
    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?
    weak var delegate: MyChatCellProtocol?
    var message: Message! {
        didSet {
            updateMessage()
        }
    }

    @IBOutlet weak var bubbleleadingconstrainsts: NSLayoutConstraint!

    @IBOutlet weak var bottommediaviewConstrains: NSLayoutConstraint!


    @IBOutlet weak var lbltextleadingconstrainsts: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleImage: UIImageView!
    
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var hieghtView: NSLayoutConstraint!

    @IBOutlet weak var messagecviewleftconstraints: NSLayoutConstraint!

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
    @IBOutlet weak var labelText: UITextView!
//    weak var delegate2: ChatMessageCellProtocol? {
//        didSet {
//            labelText.delegate = delegate2
//        }
//    }

    
    @IBOutlet weak var mediaViews: UIStackView!
    @IBOutlet weak var mediaViewsHeightConstraint: NSLayoutConstraint!
    
    static func cellMediaHeightFor(message: Message, sequential: Bool = true) -> CGFloat {
        print("message array from respoonse\(message)")
        let fullWidth = UIScreen.main.bounds.size.width - 30
        let attributedString = MessageTextCacheManager.shared.message(for: message)
        let height = attributedString?.heightForView(withWidth: fullWidth )
        //        let starWidth = (message.text.widthOfString(usingFont: UIFont.systemFont(ofSize: 14))) + 16
        //        let starhieght = (message.text.heightOfString(usingFont: UIFont.systemFont(ofSize: 14))) + 16
          var total: CGFloat = 0
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
            total += Actionlinkview.defaultHeight
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
    
    // MARK: Sequential
    @IBOutlet weak var labelUsernameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerHeightConstraint: NSLayoutConstraint!
    
    var sequential: Bool = false {
        didSet {
           // avatarContainerHeightConstraint.constant = sequential ? 0 : 35
           // labelUsernameHeightConstraint.constant = sequential ? 0 : 21
           // labelDateHeightConstraint.constant = sequential ? 0 : 21
        }
    }
    
    override func prepareForReuse() {
        labelUsername.text = ""
        labelText.text = ""
        labelDate.text = ""
        sequential = false
        
        for view in mediaViews.arrangedSubviews {
            view.removeFromSuperview()
        }
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

    func insertvideolink() -> CGFloat {
        var addedHeight = CGFloat(0)// guard url.isValid() else { return }
         message.actionL.forEach { obj in
            if let view = Actionlinkview.instantiateFromNib() {
                print("obj.params 2 -\(obj.params ?? "")")
                view.stringParma = obj.params
               // view.btnClicktoJoin.addTarget(self, action: #selector(openvideo(id:)), for: UIControlEvents.touchUpInside)
                mediaViews.addArrangedSubview(view)
                addedHeight += Actionlinkview.defaultHeight
            }
        }
        return addedHeight
    }

//    @objc func openvideo(id: String) {
//        if let loginVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChannelInfoViewController") as? ChannelInfoViewController {
//            let navigationController = BaseNavigationController(rootViewController: loginVC)
//            let b = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: Selector(("cancelClicked:")))
//            navigationController.navigationItem.backBarButtonItem = b
//            let appDelegate = UIApplication.shared.delegate as? AppDelegate
//            appDelegate?.window?.rootViewController?.present(navigationController, animated: true, completion: {
//                //  textView.text.insert("@", at: textView.text.startIndex)
//
//            })
//        }
//    }

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
            let name = message.user?.displayName() ?? "unknown"
            labelUsername.text = name
        }
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
         labelText.textAlignment = .right

//        if let text = MessageTextCacheManager.shared.message(for: message) {
////            if message.temporary {
////                text.setFontColor(MessageTextFontAttributes.systemFontColor)
////            }
//
//            // labelText.attributedText = text
////            if text.string.hasPrefix("@") {
//           // labelText.attributedText = resolveHashTags(text: text.string)
////            } else {
////                labelText.attributedText = text
////            }
//            labelText.attributedText = text
////            labelText.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.link]
////            labelText.dataDetectorTypes = .all
//            labelText.textAlignment = .right
//        }
    }
    
    func getColoredText(text: String) -> NSMutableAttributedString {
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.components(separatedBy:" ")
        var w = ""

        for word in words {
            if (word.hasPrefix("@") && word.hasSuffix("@")) {
                let range:NSRange = (string.string as NSString).range(of: word)
                string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
                w = word.replacingOccurrences(of: "@", with: "")
                w = w.replacingOccurrences(of:"@", with: "")
                string.replaceCharacters(in: range, with: w)
            }
        }
        return string
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
        
        if !sequential {
            updateMessageHeader()
        }
        // updateMessageHeader()
        updateMessageContent()
        
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

extension MyChatCell: UIGestureRecognizerDelegate {
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
    
}




extension String {

    func widthForView(withWidth width: CGFloat) -> CGFloat? {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size,
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)

        return rect.width
    }

    public func separate1(withChar char : String) -> [String]{
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
extension MyChatCell: UITextViewDelegate {
    
    
    
    func cancelClicked(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

//    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return false
//    }

//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        OperationQueue.main.addOperation({ () -> Void in
//
//        UIMenuController.shared.setMenuVisible(false, animated: false)
//        self.resignFirstResponder()
//        })
//        if action == #selector(paste(_:)) ||
//            action == #selector(cut(_:)) ||
//            action == #selector(copy(_:)) ||
//            action == #selector(select(_:)) ||
//            action == #selector(selectAll(_:)) ||
//            action == #selector(delete(_:)) ||
//            action == #selector(makeTextWritingDirectionLeftToRight(_:)) ||
//            action == #selector(makeTextWritingDirectionRightToLeft(_:)) ||
//            action == #selector(toggleBoldface(_:)) ||
//            action == #selector(toggleItalics(_:)) ||
//            action == #selector(toggleUnderline(_:)) {
//            return true
//        }
//
//        return true
//    }


    //For iOS 10
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


