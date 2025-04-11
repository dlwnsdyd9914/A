//
//  TweetViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class TweetViewModel: TweetViewModelProtocol {

    private var tweet: TweetModelProtocol
    let userViewModel: UserViewModelProtocol

    init(tweet: TweetModelProtocol) {
        self.tweet = tweet
        self.userViewModel = UserViewModel(user: tweet.user)
    }

    var caption: String {
        return tweet.caption
    }

    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timeStamp, to: now) ?? "2m"
    }

    var tweetId: String {
        return tweet.tweetId
    }

    var infoLabel: NSAttributedString {
           let title = NSMutableAttributedString(string: userViewModel.fullname, attributes: [
               .font : UIFont.boldSystemFont(ofSize: 14)
           ])
           title.append(NSAttributedString(string: " @\(userViewModel.username)", attributes: [
               .font : UIFont.systemFont(ofSize: 12),
               .foregroundColor : UIColor.lightGray
           ]))
           title.append(NSAttributedString(string: " · \(timestamp)", attributes: [
               .font : UIFont.systemFont(ofSize: 14),
               .foregroundColor : UIColor.lightGray
           ]))
           return title
       }

    var profileImageUrl: URL? {
        return userViewModel.profileImageUrl
    }





}
