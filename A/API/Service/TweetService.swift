//
//  TweetService.swift
//  A
//
//

import UIKit
import Firebase

/// 트윗 관련 모든 Firebase 데이터 처리 로직을 담당하는 서비스 클래스입니다.
///
/// - 역할:
///     - 트윗 업로드, 좋아요/언좋아요 처리, 리트윗, 댓글(Reply) 등록 등 주요 트윗 관련 비즈니스 로직 수행
///     - 트윗에 연결된 유저 데이터까지 함께 매핑하여 뷰모델에서 바로 사용할 수 있도록 구성
///
/// - 주요 사용처:
///     - UploadTweetUseCase, TweetLikeUseCase, ProfileUseCase 등 다양한 도메인 레이어에서 호출
///     - 트윗 업로드, 피드 로딩, 좋아요 처리 등 트윗 기능이 필요한 모든 곳에서 사용
///
/// - 설계 이유:
///     - Firebase와 직접 통신하는 로직은 Repository(Service)에서 처리하도록 분리하여 SRP를 지킴
///     - 트윗 데이터 구조와 사용자(User) 데이터를 함께 매핑해주는 역할을 분리함으로써 ViewModel의 책임 최소화
class TweetService {

    // MARK: - Typealias
    typealias CompletionHandler = (Result<Tweet, TweetServiceError>) -> Void

    // MARK: - Dependencies
    private let notificationService = NotificationService()

    // MARK: - 트윗 업로드 (신규 트윗 or 리플)
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        let date = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(.unknown))
            return
        }

        var values: [String: Any] = [
            "caption": caption,
            "timestamp": date,
            "likes": 0,
            "retweets": 0,
            "uid": uid
        ]

        switch type {
        case .tweet:
            FirebasePath.tweets.childByAutoId().updateChildValues(values) {[weak self] error, ref in
                guard let self else { return }
                if error != nil {
                    completion(.failure(.failedToUpload))
                    return
                }

                guard let tweetId = ref.key else { return }
                FirebasePath.userTweets.child(uid).updateChildValues([tweetId: 1]) { error, ref in
                    self.updateUserFeed(tweetId: tweetId)
                    completion(.success(()))
                }
            }

        case .reply(let tweet):
            values["replyingTo"] = tweet.user.userName
            FirebasePath.tweetReplies.child(tweet.tweetId).childByAutoId().updateChildValues(values) {[weak self] error, ref in
                guard let self else { return }
                guard let key = ref.key else { return }

                FirebasePath.userReplies.child(uid).updateChildValues([tweet.tweetId : key])
                notificationService.uploadNotification(type: .reply, tweet: tweet, caption: caption)
                completion(.success(()))
            }
        }
    }

    // MARK: - 업로드된 트윗을 팔로워 피드에 추가
    private func updateUserFeed(tweetId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let values = [tweetId: 1]
        FirebasePath.userFollowing.child(currentUid).observe(.childAdded) { snapshot in
            let key = snapshot.key
            FirebasePath.userFeeds.child(key).updateChildValues(values)
        }
    }

    // MARK: - 전체 트윗 피드 가져오기
    func fetchAllTweets(completion: @escaping CompletionHandler) {
        FirebasePath.tweets.observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            guard let tweetValue = snapshot.value as? [String: Any],
                  let userUid = tweetValue["uid"] as? String else { return }

            UserFactory.fetchUser(uid: userUid) { result in
                switch result {
                case .success(let user):
                    let tweet = Tweet(tweetId: tweetId, dictionary: tweetValue, user: user)
                    completion(.success(tweet))
                case .failure:
                    completion(.failure(.failedToFetch))
                }
            }
        }
    }

    func fetchTweet(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        FirebasePath.tweets.child(tweetId).observeSingleEvent(of: .value) { snapshot in
            guard let tweetData = snapshot.value as? [String: Any],
                  let userUid = tweetData["uid"] as? String else { return }
            UserFactory.fetchUser(uid: userUid) { result in
                switch result {
                case .success(let user):
                    let tweet = Tweet(tweetId: tweetId, dictionary: tweetData, user: user)
                    completion(.success(tweet))
                case .failure:
                    print("❌ 사용자 정보 가져오기 실패 (uid: \(userUid))")
                    completion(.failure(.failedToFetch))
                }
            }

        }
    }

    // MARK: - 특정 유저의 트윗을 실시간으로 가져오기
    func selectFetchTweets(uid: String, completion: @escaping CompletionHandler) {
        FirebasePath.userTweets.child(uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            FirebasePath.tweets.child(tweetId).observeSingleEvent(of: .value) { snapshot in
                guard let tweetData = snapshot.value as? [String: Any],
                      let userUid = tweetData["uid"] as? String else {
                    completion(.failure(.failedToFetch))
                    return
                }

                UserFactory.fetchUser(uid: userUid) { result in
                    switch result {
                    case .success(let user):
                        let tweet = Tweet(tweetId: tweetId, dictionary: tweetData, user: user)
                        completion(.success(tweet))
                    case .failure:
                        completion(.failure(.failedToFetch))
                    }
                }
            }
        }
    }

    // MARK: - 좋아요/좋아요 취소 처리
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(.failure(.unauthorized))
            return
        }

        let tweetId = tweet.tweetId
        let isLiked = tweet.didLike

        FirebasePath.tweets.child(tweetId).child("likes").runTransactionBlock { currentData in
            var count = currentData.value as? Int ?? 0
            count = isLiked ? max(count - 1, 0) : count + 1
            currentData.value = count
            return .success(withValue: currentData)

        } andCompletionBlock: { error, _, _ in
            if let error = error {
                completion(.failure(isLiked ? .failedToUnlike : .failedToLike))
                return
            }

            if isLiked {
                // 좋아요 취소 처리
                FirebasePath.tweetLikes.child(tweetId).child(currentUid).removeValue { error, _ in
                    if error != nil {
                        completion(.failure(.failedToUnlike))
                        return
                    }
                    FirebasePath.userLikes.child(currentUid).child(tweetId).removeValue { error, _ in
                        if error != nil {
                            completion(.failure(.failedToUnlike))
                        } else {
                            completion(.success(false))
                        }
                    }
                }
            } else {
                // 좋아요 추가 처리
                FirebasePath.tweetLikes.child(tweetId).updateChildValues([currentUid: 1]) { error, _ in
                    if error != nil {
                        completion(.failure(.failedToLike))
                        return
                    }

                    FirebasePath.userLikes.child(currentUid).updateChildValues([tweetId: 1]) {[weak self] error, _ in
                        if let self = self {
                            self.notificationService.uploadNotification(type: .like, tweet: tweet)
                            completion(.success(true))
                        }
                    }
                }
            }
        }
    }

    // MARK: - 현재 로그인 유저가 해당 트윗에 좋아요 눌렀는지 확인
    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        FirebasePath.tweetLikes.child(tweet.tweetId).child(currentUid).observe(.value) { snapshot in
            completion(snapshot.exists())
        }
    }

    // MARK: - 좋아요 누른 트윗 가져오기
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void)) {
        FirebasePath.userLikes.child(uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            FirebasePath.tweets.child(tweetId).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let tweetUid = value["uid"] as? String else { return }

                UserFactory.fetchUser(uid: tweetUid) { result in
                    switch result {
                    case .success(let user):
                        let tweet = Tweet(tweetId: tweetId, dictionary: value, user: user)
                        completion(tweet)
                    case .failure:
                        completion(nil)
                    }
                }
            }
        }
    }

    // MARK: - 리플 가져오기
    func fetchTweetReplies(tweetId: String, completion: @escaping CompletionHandler) {
        FirebasePath.tweetReplies.child(tweetId).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            guard let value = snapshot.value as? [String: Any],
                  let uid = value["uid"] as? String else { return }

            UserFactory.fetchUser(uid: uid) { result in
                switch result {
                case .success(let user):
                    let tweet = Tweet(tweetId: tweetID, dictionary: value, user: user)
                    completion(.success(tweet))
                case .failure:
                    completion(.failure(.failedToFetch))
                }
            }
        }
    }

    // MARK: - 유저가 남긴 모든 리플 가져오기
    func fetchReplies(uid: String, completion: @escaping CompletionHandler) {
        FirebasePath.userReplies.child(uid).observe(.childAdded) { snapshot in
            let key = snapshot.key
            guard let value = snapshot.value as? String else { return }

            FirebasePath.tweetReplies.child(key).child(value).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let tweetUid = value["uid"] as? String else { return }

                UserFactory.fetchUser(uid: tweetUid) { result in
                    switch result {
                    case .success(let user):
                        let tweet = Tweet(tweetId: key, dictionary: value, user: user)
                        completion(.success(tweet))
                    case .failure:
                        completion(.failure(.unauthorized))
                    }
                }
            }
        }
    }
}
