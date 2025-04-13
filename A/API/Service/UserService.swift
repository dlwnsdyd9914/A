//
//  UserService.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase

class UserService {

    private let notificationService = NotificationService()

    typealias CompletionHandler = (Result<User, UserServiceError>) -> Void

    func getCurrentUser(completion: @escaping CompletionHandler) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        UserFactory.fetchUser(uid: currentUid) { result  in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(.dataParsingError))
            }
        }
    }

    func fetchSelectedUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        UserFactory.fetchUser(uid: uid) {  result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        FirebasePath.users.observe(.childAdded) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(.userNotFound))
                return
            }
            let key = snapshot.key
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }
            let user = User(uid: key, dictionary: value)
            completion(.success(user))
        }
    }

    func follow(uid: String, completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        FirebasePath.userFollowing.child(currentUid).updateChildValues([uid: 1]) { error, ref in
            FirebasePath.userFollowers.child(uid).updateChildValues([currentUid: 1]) { error, ref in

                FirebasePath.userTweets.child(uid).observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let self else { return }

                    if let children = snapshot.children.allObjects as? [DataSnapshot] {
                        for tweet in children {
                            let key = tweet.key
                            FirebasePath.userFeed.child(currentUid).updateChildValues([key: 1])
                        }
                    }

                    notificationService.uploadNotification(type: .follow, toUid: uid)
                    completion()
                }
            }
        }
    }


    func unFollow(uid: String, completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        FirebasePath.userFollowing.child(currentUid).child(uid).removeValue { error, ref in
            FirebasePath.userFollowers.child(uid).child(currentUid).removeValue { error, ref in

                FirebasePath.userTweets.child(uid).observeSingleEvent(of: .value) { snapshot in
                    if let children = snapshot.children.allObjects as? [DataSnapshot] {
                        for tweet in children {
                            let key = tweet.key
                            FirebasePath.userFeed.child(currentUid).child(key).removeValue()
                            completion()
                        }
                    }
                }
            }
        }
    }

    func checkingFollow(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        FirebasePath.userFollowing.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(uid) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void) {
        var followerCount = 0
        var followingCount = 0

        FirebasePath.userFollowers.child(uid).observe(.value) { snapshot in
            if let followers = snapshot.value as? [String: Any] {
                followerCount = followers.count
            } else {
                followerCount = 0
            }
            completion(followingCount, followerCount)
        }

        FirebasePath.userFollowing.child(uid).observe(.value) { snapshot in
            if let followings = snapshot.value as? [String: Any] {
                followingCount = followings.count
            } else {
                followingCount = 0
            }
            completion(followingCount, followerCount)
        }
    }



}
