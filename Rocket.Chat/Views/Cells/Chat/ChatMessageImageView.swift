//
//  ChatMessageImageView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage

protocol ChatMessageImageViewProtocol: class {
    func openImageFromCell(attachment: Attachment, thumbnail: FLAnimatedImageView)
}

final class ChatMessageImageView: UIView {
    static var defaultHeight = CGFloat(250)
     static var defaultwidth = CGFloat(300)

    weak var delegate: ChatMessageImageViewProtocol?
    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }
    var imageViewChat: UIImageView?

    @IBOutlet weak var viewforimagechatview: UIView!
    @IBOutlet weak var lblimgDesc: UILabel!

    @IBOutlet weak var viewtitlehieghtconstraints: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var activityIndicatorImageView: UIActivityIndicatorView!

    @IBOutlet weak var imageviewheightConstrainsts: NSLayoutConstraint!
    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
          //  imageView.backgroundColor = UIColor.red
        }
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapView))
    }()

    fileprivate func updateMessageInformation() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }
        labelTitle.text = attachment.title
        if attachment.title == "" || attachment.title == nil {
            viewtitlehieghtconstraints.constant = 0
        } else {
            viewtitlehieghtconstraints.constant = 30
        }
        lblimgDesc.text = attachment.desc1
        if attachment.desc1 == "" || attachment.desc1 == nil {
            lblimgDesc.backgroundColor = UIColor.clear
        }
        else {
            lblimgDesc.backgroundColor = UIColor.white
        }
        let imageURL = attachment.fullImageURL()
        activityIndicatorImageView.startAnimating()
        imageView.sd_setImage(with: imageURL, completed: { [weak self] _, _, _, _ in
//            guard let url = imageURL else { fatalError("Bad URL") }
//            guard let data = NSData.init(contentsOf: url) else { fatalError("Bad data") }
//            guard let img = UIImage(data: data as Data) else { fatalError("Bad data") }

            let outImageFit = self?.imageView.image?.resizedImageWithinRect(rectSize: CGSize(width: 200, height: 200))
            let outImageFill = self?.imageView.image?.resizedImage(newSize: CGSize(width: 200, height: 200))
            self?.activityIndicatorImageView.stopAnimating()
            if self?.imageView.image != nil {
                self?.imageView.image = outImageFit
//                if (self?.imageView.frame.size.width)! < CGFloat((self?.imageView.image?.size.width)!) {
//                    self?.imageviewheightConstrainsts.constant = (self?.imageView.frame.size.width)! / (self?.imageView.image?.size.width)! * (self?.imageView.image?.size.height)!
//                    ChatMessageImageView.defaultHeight = (self?.imageviewheightConstrainsts.constant)! + 30
//                }
//                if (self?.imageView.frame.size.height)! < CGFloat((self?.imageView.image?.size.height)!) {
//                    ChatMessageImageView.defaultwidth = (self?.imageView.frame.size.height)! / (self?.imageView.image?.size.height)! * (self?.imageView.image?.size.height)!
//                }
               // self?.imageView.center = (self?.imageView.superview?.center)!
            }

        })

    }

    @objc func didTapView() {
        delegate?.openImageFromCell(attachment: attachment, thumbnail: imageView)
    }
}
extension UIImage {

    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height

        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }

        //let newSize = CGSizeMake(size.width/resizeFactor, size.height/resizeFactor)
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }

}
