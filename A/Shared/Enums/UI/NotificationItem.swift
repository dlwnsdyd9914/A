//
//  NotificationItem.swift
//  A
//
//

import UIKit

struct NotificationItem {
    let notification: Notification
    let user: User
    let tweet: Tweet? // 트윗이 필요한 알림만 해당
}
