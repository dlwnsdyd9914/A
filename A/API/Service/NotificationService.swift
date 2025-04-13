//
//  NotificationService.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit
import Firebase

class NotificationService {
    func uploadNotification(type: NotificationType, tweet: TweetModelProtocol? = nil, caption: String? = nil, toUid: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970

        var values: [String: Any] = [
            "fromUid" : uid,
            "timestamp" : timestamp,
            "type" : type.rawValue,
            "isRead": false  // 
        ]

        if let caption = caption {
            values["caption"] = caption
        }

        if let tweet = tweet {
            values["tweetID"] = tweet.tweetId
            FirebasePath.notifications.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let toUid = toUid {
            FirebasePath.notifications.child(toUid).childByAutoId().updateChildValues(values)
        }
    }

    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(.unauthorized))
            return
        }

        var notifications: [Notification] = []

        FirebasePath.notifications.child(uid).observe(.childAdded) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.decodingFailed))
                return
            }
            let id = snapshot.key

            let notification = Notification(id: id, dictionary: value)

            // ✅ 자기 자신이 보낸 알림이면 무시
            if notification.fromUid == uid { return }

            if !notifications.contains(where: { $0.id == id }) {
                notifications.append(notification)
            }



            let sorted = notifications.sorted(by: { $0.timestamp > $1.timestamp })
            completion(.success(sorted))
        }
    }



}
