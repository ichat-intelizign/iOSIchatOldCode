//
//  ChatControllerAutocomplete.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension ChatViewController {

    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {


        searchResult = [AllUserModel]()

        if prefix == "@" && word.characters.count > 0 {
            for user  in arralluser {
                if (user.nameAll?.localizedStandardContains(word))! {
                    searchResult.append(user)
                }
            }
        }
//
        let show = (searchResult.count > 0)
        showAutoCompletionView(show)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return AutocompleteCell.minimumHeight * CGFloat(searchResult.count)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return autoCompletionCellForRowAtIndexPath(indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AutocompleteCell.minimumHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = searchResult[indexPath.row] as AllUserModel
        acceptAutoCompletion(with: "\(key.usernameAll ?? "") ", keepPrefix: true)

    }

    private func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> AutocompleteCell {
        guard let cell = autoCompletionView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier) as? AutocompleteCell else {
            return AutocompleteCell(style: .`default`, reuseIdentifier: AutocompleteCell.identifier)
        }
        cell.selectionStyle = .default

        let key = searchResult[indexPath.row] as AllUserModel
//        if let user = searchResult[key] as? User {
//            cell.avatarView.isHidden = false
//            cell.imageViewIcon.isHidden = true
//            cell.avatarView.user = user
//        } else {
//            cell.avatarView.isHidden = true
//            cell.imageViewIcon.isHidden = false
//
//            if let image = searchResult[key] as? UIImage {
//                cell.imageViewIcon.image = image.imageWithTint(.lightGray)
//            }
//        }

        cell.avatarView.imageURL = URL(string: "https://ichat.intelizi.com/avatar/\(key.usernameAll ?? "")")

        cell.labelTitle.text = key.nameAll
        return cell
    }
}
