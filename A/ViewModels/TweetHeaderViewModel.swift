//
//  TweetHeaderViewModel.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class TweetHeaderViewModel: TweetHeaderViewModelProtocol {

    
    private var tweet: TweetModelProtocol
    private(set) var userViewModel: UserViewModel

    init(tweet: TweetModelProtocol) {
        self.tweet = tweet
        self.userViewModel = UserViewModel(user: tweet.user as UserModelProtocol)
    }

    var caption: String {
        return tweet.caption
    }

    var fullname: String {
        return tweet.user.fullName
    }

    var username: String {
        return tweet.user.userName
    }

    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    var retweetAttributedString: NSAttributedString {
        return funcAttributedText(value: tweet.retweets, text: "Retweets")
    }

    var likesAttributedString: NSAttributedString {
        return funcAttributedText(value: tweet.lieks, text: "likes")
    }

    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ∙ MM/dd/yyyy"
        return formatter.string(from: tweet.timeStamp)
    }

    var infoLabel: NSAttributedString {
        let title = NSMutableAttributedString(string: tweet.user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(tweet.user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        title.append(NSAttributedString(string: " . \(headerTimestamp)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                                                      NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    var handleShowActionSheet: (() -> Void)?

    func funcAttributedText(value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedText
    }

    func showActionSheet() {
        handleShowActionSheet?()
    }
}
