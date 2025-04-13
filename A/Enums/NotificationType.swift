//
//  NotificationType.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

enum NotificationType: String, CustomStringConvertible {
    case follow
    case like
    case reply
    case retweet
    case mention

    var description: String {
        switch self {
        case .follow:
            return "follow"
        case .like:
            return "like"
        case .reply:
            return "reply"
        case .retweet:
            return "retweet"
        case .mention:
            return "mention"
        }
    }
}

