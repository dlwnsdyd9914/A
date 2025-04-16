//
//  Notification.swift
//  A
//
//

import UIKit

/// 파이어베이스에서 가져온 알림 데이터를 모델링한 클래스입니다.
/// - 역할: `NotificationModelProtocol`을 채택하여 알림 타입, 보낸 사람 UID, 트윗 ID 등 다양한 정보를 저장
/// - 주요 사용처: NotificationUseCase, NotificationViewModel 등에서 활용됨
final class Notification: NotificationModelProtocol {

    // MARK: - Properties

    /// 고유 알림 ID (문서 ID)
    var id: String

    /// 알림이 생성된 시각
    var timestamp: Date

    /// 알림 타입 (팔로우, 멘션, 좋아요 등)
    var type: NotificationType?

    /// 멘션/댓글/리트윗 등에서 표시될 트윗 본문
    var caption: String?

    /// 해당 트윗 ID (트윗 관련 알림에만 해당)
    var tweetID: String?

    /// 알림을 발생시킨 유저의 UID
    var fromUid: String

    /// 알림 읽음 여부
    var isRead: Bool

    // MARK: - Initializer

    /// 파이어베이스에서 가져온 딕셔너리 데이터를 기반으로 알림 모델 생성
    /// - Parameters:
    ///   - id: 파이어스토어 문서 ID
    ///   - dictionary: 파이어스토어 문서의 필드 값
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.fromUid = dictionary["fromUid"] as? String ?? ""
        self.tweetID = dictionary["tweetID"] as? String
        self.caption = dictionary["caption"] as? String
        self.isRead = dictionary["isRead"] as? Bool ?? false

        // 알림 타입 디코딩
        if let typeRaw = dictionary["type"] as? String {
            self.type = NotificationType(rawValue: typeRaw)
        }

        // 타임스탬프 디코딩
        if let timestampValue = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestampValue)
        } else {
            self.timestamp = Date()
        }
    }
}

