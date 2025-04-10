//
//  FirebasePath.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase

enum FirebasePath {
    static let db = Database.database().reference()

    static let users = db.child("users")
    static let tweets = db.child("tweets")
    static let userTweets = db.child("user-tweet")
    static let userFollowers = db.child("user-follower")
    static let userFollowing = db.child("user-following")
    static let tweetReplies = db.child("tweet-replies")
    static let tweetLikes = db.child("tweet-likes")
    static let userFeed = db.child("user-feed")
    static let notifications = db.child("notifications")

    static let storage = Storage.storage().reference()
    static let profileImages = storage.child("user-profiles")
}

