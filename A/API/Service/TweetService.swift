//
//  TweetService.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Firebase

class TweetService {

    typealias CompletionHandler = (Result<Tweet, TweetServiceError>) -> Void

    private let notificationService = NotificationService()


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
                let key = ref.key
                FirebasePath.userReplies.child(uid).updateChildValues([tweet.tweetId : key!])
                notificationService.uploadNotification(type: .reply, tweet: tweet, caption: caption)
                completion(.success(()))
            }
        }
    }

    private func updateUserFeed(tweetId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let values = [tweetId: 1]

        FirebasePath.userFollowing.child(currentUid).observe(.childAdded) { snapshot in
            let key = snapshot.key
            FirebasePath.userFeed.child(key).updateChildValues(values)
        }
    }

    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

        FirebasePath.tweets.observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            guard let tweetValue = snapshot.value as? [String: Any],
                  let userUid = tweetValue["uid"] as? String else { return }

            UserFactory.fetchUser(uid: userUid) { result in
                switch result {
                case .success(let user):
                    let tweet = Tweet(tweetId: tweetId, dictionary: tweetValue, user: user)
                    completion(.success(tweet))
                case .failure(_):
                    completion(.failure(.failedToFetch))
                }
            }
        }
    }

    func selectFetchTweets(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        FirebasePath.userTweets.child(uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            print("📝 [실시간] 트윗 ID: \(tweetId)")

            FirebasePath.tweets.child(tweetId).observeSingleEvent(of: .value) { snapshot in
                guard
                    let tweetData = snapshot.value as? [String: Any],
                    let userUid = tweetData["uid"] as? String
                else {
                    print("❌ 트윗 데이터 파싱 실패: \(snapshot)")
                    return completion(.failure(.failedToFetch))
                }

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

                case .failure(let error):
                    print("❌ 리플 유저 정보 에러: \(error)")
                }
            }
        }
    }

    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(.failure(.unauthorized))
            return
        }

        let tweetId = tweet.tweetId
        let isLiked = tweet.didLike

        // 트랜잭션: 좋아요 숫자 증가/감소 처리
        FirebasePath.tweets.child(tweetId).child("likes").runTransactionBlock { currentData in
            var count = currentData.value as? Int ?? 0
            count = isLiked ? max(count - 1, 0) : count + 1
            currentData.value = count
            return .success(withValue: currentData)

        } andCompletionBlock: { error, _, _ in
            if let error = error {
                print("🔥 트랜잭션 실패:", error.localizedDescription)
                completion(.failure(isLiked ? .failedToUnlike : .failedToLike))
                return
            }

            // 좋아요 취소
            if isLiked {
                FirebasePath.tweetLikes.child(tweetId).child(currentUid).removeValue { error, _ in
                    if let error = error {
                        print("🔥 좋아요 제거 실패:", error.localizedDescription)
                        completion(.failure(.failedToUnlike))
                        return
                    }

                    FirebasePath.userLikes.child(currentUid).child(tweetId).removeValue { error, _ in
                        if let error = error {
                            print("🔥 유저 좋아요 제거 실패:", error.localizedDescription)
                            completion(.failure(.failedToUnlike))
                        } else {
                            completion(.success((false)))
                        }
                    }
                }

            // 좋아요 추가
            } else {
                FirebasePath.tweetLikes.child(tweetId).updateChildValues([currentUid: 1]) { error, _ in
                    if let error = error {
                        print("🔥 좋아요 추가 실패:", error.localizedDescription)
                        completion(.failure(.failedToLike))
                        return
                    }

                    FirebasePath.userLikes.child(currentUid).updateChildValues([tweetId: 1]) {[weak self] error, _ in
                        guard let self else { return }
                        if let error = error {
                            print("🔥 유저 좋아요 추가 실패:", error.localizedDescription)
                            completion(.failure(.failedToLike))
                        } else {
                            notificationService.uploadNotification(type: .like, tweet: tweet)
                            completion(.success((true)))
                        }
                    }
                }
            }
        }
    }

    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        FirebasePath.tweetLikes.child(tweet.tweetId).child(currentUid).observe(.value) { snapshot in
            completion(snapshot.exists())
        }
    }



}
