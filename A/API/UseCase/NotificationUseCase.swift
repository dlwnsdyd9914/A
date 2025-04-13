//
//  NotificationUseCase.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

final class NotificationUseCase: NotificationUseCaseProtocol {

    private let repository: NotificationRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let tweetRepository: TweetRepositoryProtocol

    init(repository: NotificationRepositoryProtocol, userRepository: UserRepositoryProtocol, tweetRepository: TweetRepositoryProtocol) {
        self.repository = repository
        self.userRepository = userRepository
        self.tweetRepository = tweetRepository

    }

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


    private func fetchUserTweet(notification: Notification, completion: @escaping (NotificationItem?) -> Void) {


        userRepository.fetchSelectedUser(uid: notification.fromUid) { [weak self] result in
            guard let self else {
                completion(nil)
                return
            }

            switch result {
            case .success(let user):
                guard let tweetID = notification.tweetID else {
                    let item = NotificationItem(notification: notification, user: user, tweet: nil)
                    completion(item)
                    return
                }

                tweetRepository.fetchTweet(tweetId: tweetID) { tweetResult in
                    let tweet: Tweet? = (try? tweetResult.get()) // 실패 시 nil
                    let item = NotificationItem(notification: notification, user: user, tweet: tweet)
                    completion(item)
                }

            case .failure:
                completion(nil)
            }
        }
    }




}
