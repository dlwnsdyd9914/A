//
//  TweetDestination.swift
//  A
//
//

import Foundation

enum TweetDestination {
    case uploadTweet(userViewModel: UserViewModel)
    case uploadReply(userViewModel: UserViewModel, tweet: TweetModelProtocol)

}
