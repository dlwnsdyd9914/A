//
//  Notification.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

class Notification: NotificationModelProtocol {

    var id: String

    var timestamp: Date
    var type: NotificationType?
    var caption: String?
    var tweetID: String?
    var fromUid: String
    var isRead: Bool

    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.fromUid = dictionary["fromUid"] as? String ?? ""
        self.tweetID = dictionary["tweetID"] as? String
        self.caption = dictionary["caption"] as? String
        self.isRead = dictionary["isRead"] as? Bool ?? false

        if let typeRaw = dictionary["type"] as? String {
            self.type = NotificationType(rawValue: typeRaw)
        }

        if let timestampValue = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestampValue)
        } else {
            self.timestamp = Date()
        }
    }
}

