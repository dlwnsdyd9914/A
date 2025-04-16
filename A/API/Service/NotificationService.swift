//
//  NotificationService.swift
//  A
//
//

import UIKit
import Firebase

/// Firebase 기반의 알림 업로드 및 패치 기능을 담당하는 서비스 클래스입니다.
///
/// - 역할:
///     - 알림(Notification)을 생성 및 저장하고, 특정 사용자에게 푸시할 알림 데이터를 Firebase에 업로드합니다.
///     - 실시간으로 알림 데이터를 관찰(observe)하여 최신 알림 리스트를 제공합니다.
///
/// - 주요 사용처:
///     - `NotificationUseCase` → 도메인 계층에서 알림 비즈니스 로직을 추상화할 때 호출
///     - 트윗 작성, 좋아요, 멘션, 팔로우 등의 행동 발생 시 알림 생성
///
/// - 설계 이유:
///     - Firebase Database 직접 접근 로직을 UseCase에서 분리하여 SRP 원칙 유지
///     - 추후 Firebase 외의 백엔드로 교체 시, NotificationService만 교체하면 되는 구조 확보
class NotificationService {

    /// 알림을 업로드합니다.
    /// - Parameters:
    ///   - type: 알림 타입 (팔로우, 좋아요, 멘션 등)
    ///   - tweet: 트윗 정보 (멘션/좋아요 등 트윗 기반 알림 시 필요)
    ///   - caption: 멘션 내용 등 필요한 경우 표시할 텍스트
    ///   - toUid: 특정 유저에게 직접 알림을 보내야 할 경우 사용
    func uploadNotification(type: NotificationType, tweet: TweetModelProtocol? = nil, caption: String? = nil, toUid: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970

        var values: [String: Any] = [
            "fromUid": uid,
            "timestamp": timestamp,
            "type": type.rawValue,
            "isRead": false  // 최초 업로드 시 읽지 않은 상태
        ]

        if let caption = caption {
            values["caption"] = caption
        }

        if let tweet = tweet {
            // 트윗 기반 알림일 경우 해당 트윗 작성자의 알림 노드에 저장
            values["tweetID"] = tweet.tweetId
            FirebasePath.notifications.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let toUid = toUid {
            // 특정 유저에게 직접 알림을 보낼 경우
            FirebasePath.notifications.child(toUid).childByAutoId().updateChildValues(values)
        }
    }

    /// 알림 데이터를 패치합니다.
    /// - Parameter completion: 결과 콜백 (성공 시 [Notification], 실패 시 에러)
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

            // ✅ 자기 자신이 보낸 알림은 UI에 표시하지 않음
            if notification.fromUid == uid { return }

            // ✅ 중복 방지 후 추가
            if !notifications.contains(where: { $0.id == id }) {
                notifications.append(notification)
            }

            completion(.success(notifications))
        }
    }
}
