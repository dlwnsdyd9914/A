//
//  NotificationDestination.swift
//  A
//
//

import UIKit

enum NotificationDestination {
    case tweetDetail(tweetViewModel: TweetViewModel, userViewModel: UserViewModel)
    case userProfile(userViewModel: UserViewModel)
}

