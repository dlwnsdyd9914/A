//
//  Tweet.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class Tweet: TweetModelProtocol {
    var caption: String
    
    var lieks: Int
    
    var retweets: Int
    
    var timeStamp: Date
    
    var tweetId: String
    
    var uid: String
    
    var user: User
    
    var didLike: Bool = false
    
    var replyingTo: String?
    
    var isRely: Bool {
        return !(replyingTo?.isEmpty ?? true)
    }

    init(tweetId: String, dictionary: [String: Any], user: User) {
        self.user = user
        self.tweetId = tweetId

        self.uid = dictionary["uid"] as? String ?? ""
        self.lieks = dictionary["likes"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        self.caption = dictionary["caption"] as? String ?? ""
        self.replyingTo = dictionary["replyingTo"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Double {
            self.timeStamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timeStamp = Date()
        }
    }


}
