//
//  NotificationUseCase.swift
//  A
//
//

import UIKit

/// 알림 데이터를 비즈니스 로직 흐름에 맞춰 가공하는 유즈케이스입니다.
///
/// - 역할:
///     - 파이어베이스로부터 알림(Notification)을 받아와서,
///       각 알림에 연관된 유저 정보와 트윗 정보를 조회한 뒤 `NotificationItem`으로 조합합니다.
///     - `NotificationViewModel`에서 호출되어 화면에 필요한 알림 정보들을 제공합니다.
///
/// - 주요 사용처:
///     - `NotificationViewModel`
///     - `NotificationController` (직접 호출 X, ViewModel에서 중계)
///
/// - 구현 포인트:
///     - `DispatchGroup`을 사용하여 여러 유저 및 트윗 비동기 요청을 하나의 흐름으로 묶음
///     - 알림 타입에 따라 트윗이 필요 없는 경우엔 유저 정보만 포함하여 반환
final class NotificationUseCase: NotificationUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: NotificationRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let tweetRepository: TweetRepositoryProtocol

    // MARK: - Initializer

    init(repository: NotificationRepositoryProtocol, userRepository: UserRepositoryProtocol, tweetRepository: TweetRepositoryProtocol) {
        self.repository = repository
        self.userRepository = userRepository
        self.tweetRepository = tweetRepository
    }

    // MARK: - Public Methods

    /// 전체 알림을 가져와 유저/트윗 정보를 포함한 알림 아이템으로 변환합니다.
    /// - Parameter completion: 최종 알림 아이템 배열 전달
    func fetchNotifications(completion: @escaping (Result<[NotificationItem], NotificationServiceError>) -> Void) {
        repository.fetchNotifications { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let notifications):
                self.processNotifications(notifications: notifications) { notificationItems in
                    completion(.success(notificationItems))
                }
            case .failure(let error):
                print("❌ 알림 패치 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Methods

    /// 각 알림(Notification)에 대해 유저/트윗 데이터를 함께 묶어 NotificationItem 배열로 구성합니다.
    private func processNotifications(notifications: [Notification], completion: @escaping ([NotificationItem]) -> Void) {
        var items = [NotificationItem]()
        let group = DispatchGroup()

        for notification in notifications {
            group.enter()
            fetchUserTweet(notification: notification) { item in
                if let item = item {
                    items.append(item)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(items)
        }
    }

    /// 하나의 알림(Notification)에 대해 유저 및 트윗 데이터를 비동기로 조회하고 조합합니다.
    /// - Parameter notification: 알림 데이터
    /// - Parameter completion: 조회된 NotificationItem (nil일 수 있음)
    private func fetchUserTweet(notification: Notification, completion: @escaping (NotificationItem?) -> Void) {
        userRepository.fetchSelectedUser(uid: notification.fromUid) { [weak self] result in
            guard let self else {
                completion(nil)
                return
            }

            switch result {
            case .success(let user):
                guard let tweetID = notification.tweetID else {
                    // 트윗이 없는 알림 타입 (예: 팔로우 알림)
                    let item = NotificationItem(notification: notification, user: user, tweet: nil)
                    completion(item)
                    return
                }

                // 트윗이 있는 경우 트윗 데이터도 함께 조합
                tweetRepository.fetchTweet(tweetId: tweetID) { tweetResult in
                    let tweet: Tweet? = (try? tweetResult.get()) // 실패 시 nil 처리
                    let item = NotificationItem(notification: notification, user: user, tweet: tweet)
                    completion(item)
                }

            case .failure:
                // 유저 조회 실패 시 해당 알림 무시
                completion(nil)
            }
        }
    }
}
