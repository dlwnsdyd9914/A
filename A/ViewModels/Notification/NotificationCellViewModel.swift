//
//  NotificationCellViewModel.swift
//  A
//

//

import UIKit

/// 알림 셀에서 사용할 뷰모델입니다.
/// NotificationItem(알림 + 유저 + 트윗)을 받아 화면 표시를 위한 속성들을 제공합니다.
/// - 역할: 알림 메시지, 유저 정보, 팔로우 버튼 상태 관리
/// - 바인딩: 팔로우 상태 변경에 따른 버튼 텍스트 변경 클로저 제공
final class NotificationCellViewModel {

    // MARK: - Properties

    /// 알림 도메인 모델
    private let notification: Notification

    /// 알림 보낸 유저 정보
    private let user: User

    /// 해당 알림에 연관된 트윗 (선택적)
    private let tweet: Tweet?

    /// 팔로우 상태 토글 및 확인을 위한 유즈케이스
    private let useCase: FollowUseCaseProtocol

    // MARK: - Initializer

    init(item: NotificationItem, useCase: FollowUseCaseProtocol) {
        self.notification = item.notification
        self.user = item.user
        self.tweet = item.tweet
        self.useCase = useCase
        checkingFollow()
    }


    /// 알림 보낸 유저의 프로필 이미지 URL 문자열
    var profileImageUrl: String {
        return user.profileImageUrl
    }

    /// 알림과 연관된 트윗의 캡션 텍스트 (없을 경우 빈 문자열 반환)
    var caption: String {
        return tweet?.caption ?? ""
    }

    /// 알림과 연관된 트윗의 ID
    var tweetID: String {
        return notification.tweetID ?? ""
    }

    /// 알림 보낸 유저의 UID
    var fromUid: String {
        return notification.fromUid
    }

    /// 알림에 포함된 유저의 UID
    var uid: String {
        return user.uid
    }

    /// 알림 타입 (팔로우, 좋아요, 멘션 등)
    private var type: NotificationType? {
        return notification.type
    }

    /// 알림 문구 텍스트 생성
    var notificationText: String {
        guard let type else { return "" }

        switch type {
        case .follow:
            return "\(user.userName)님이 회원님을 팔로우했습니다."
        case .mention:
            return "\(user.userName)님이 회원님을 멘션했습니다."
        case .like:
            return "\(user.userName)님이 회원님의 트윗에 좋아요를 눌렀습니다."
        case .reply:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"에 리플을 남겼습니다."
        case .retweet:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"을 리트윗했습니다."
        }
    }

    /// 팔로우 버튼 노출 여부 (팔로우 알림일 때만 노출)
    var shouldHideFollowButton: Bool {
        return type != .follow
    }

    /// 팔로우 버튼에 표시할 텍스트
    var followButtonText: String {
        return user.didFollow ? "Following" : "Follow"
    }

    /// 팔로우 상태 플래그
    var didFollow: Bool {
        get { user.didFollow }
        set { user.didFollow = newValue }
    }

    // MARK: - Output Closures

    /// 팔로우 버튼 상태 변경 시 호출
    var onFollowToggled: (() -> Void)?

    /// 팔로우 상태 확인 후 버튼 텍스트 설정용 클로저
    var onFollowStatusCheck: ((String) -> Void)?

    // MARK: - Public Methods

    /// 팔로우 버튼 탭 시 호출
    func followButtonTapped() {
        useCase.toggleFollow(didFollow: didFollow, uid: uid) { [weak self] in
            guard let self else { return }
            self.didFollow.toggle()
            self.onFollowToggled?()
        }
    }

    /// 초기 로딩 시 팔로우 상태 확인 (비동기)
    func checkingFollow() {
        useCase.checkFollowStatus(uid: uid) { [weak self] followStatus in
            guard let self else { return }
            self.user.didFollow = followStatus
            self.onFollowStatusCheck?(followStatus ? "Following" : "Follow")
        }
    }
}
