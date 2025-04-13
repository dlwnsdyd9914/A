//
//  NotificationCellViewModel.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

/// 알림 셀에서 사용할 뷰모델입니다.
/// NotificationItem(알림 + 유저 + 트윗)을 받아 화면 표시를 위한 속성들을 제공합니다.
final class NotificationCellViewModel {

    // MARK: - Properties

    private let notification: Notification
    private let user: User
    private let tweet: Tweet?

    // MARK: - Initializer

    init(item: NotificationItem) {
        self.notification = item.notification
        self.user = item.user
        self.tweet = item.tweet
    }

    // MARK: - Computed Properties

    /// 보낸 유저의 프로필 이미지 URL
    var profileImageUrl: String {
        return user.profileImageUrl
    }

    /// 트윗 캡션 (있는 경우)
    var caption: String {
        return notification.caption ?? ""
    }

    /// 트윗 ID (있는 경우)
    var tweetID: String {
        return notification.tweetID ?? ""
    }

    /// 보낸 유저의 UID
    var uid: String {
        return notification.fromUid
    }

    /// 알림 타입
    private var type: NotificationType? {
        return notification.type
    }

    /// 알림 문구 텍스트
    var notificationText: String {
        guard let type = type else { return "" }

        switch type {
        case .follow:
            return "\(user.userName)님이 회원님을 팔로우했습니다."
        case .mention:
            return "\(user.userName)님이 회원님을 멘션했습니다."
        case .like:
            return "\(user.userName)님이 회원님의 트윗에 좋아요를 눌렀습니다."
        case .reply:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"에 댓글을 남겼습니다."
        case .retweet:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"을 리트윗했습니다."
        }
    }

    /// 팔로우 버튼 노출 여부
    var shouldHideFollowButton: Bool {
        return type != .follow
    }

    /// 팔로우 버튼 텍스트
    var followButtonText: String {
        return user.didFollow ? "Following" : "Follow"
    }
}
