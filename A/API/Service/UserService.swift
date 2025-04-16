//
//  UserService.swift
//  A
//
//

import UIKit
import Firebase

/// Firebase 기반 사용자 관련 기능을 처리하는 서비스 클래스입니다.
///
/// - 역할:
///     - 사용자 정보 조회, 전체 사용자 리스트 조회, 팔로우/언팔로우, 프로필 이미지 업로드 등 사용자 관련 기능을 제공
///     - Firebase Database 및 Storage와 직접적으로 통신
///
/// - 주요 사용처:
///     - `UserRepository` 구현체로 사용되어 도메인 계층의 유즈케이스에서 호출됨
///     - Explorer, Profile, Auth 흐름, 트윗 좋아요/작성 시 유저 데이터 동기화 등에 사용됨
///
/// - 설계 이유:
///     - 사용자 데이터 관련 Firebase 접근 코드를 UseCase와 분리해 SRP 원칙을 지키고 유지보수를 용이하게 하기 위함
 class UserService {

    // MARK: - Dependencies

    private let notificationService = NotificationService()

    // MARK: - Typealias

    typealias CompletionHandler = (Result<User, UserServiceError>) -> Void

    // MARK: - 사용자 정보 조회 메서드

    /// 현재 로그인된 사용자를 Firebase에서 조회합니다.
    func getCurrentUser(completion: @escaping CompletionHandler) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserFactory.fetchUser(uid: currentUid) { result in
            switch result {
            case .success(let user): completion(.success(user))
            case .failure: completion(.failure(.dataParsingError))
            }
        }
    }

    /// 특정 UID에 해당하는 사용자 정보 조회합니다.
    func fetchSelectedUser(uid: String, completion: @escaping CompletionHandler) {
        UserFactory.fetchUser(uid: uid) { result in
            switch result {
            case .success(let user): DispatchQueue.main.async { completion(.success(user)) }
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    /// 전체 사용자 리스트를 실시간으로 가져옵니다.
    func getAllUserList(completion: @escaping CompletionHandler) {
        FirebasePath.users.observe(.childAdded) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(.userNotFound))
                return
            }
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }
            let key = snapshot.key
            let user = User(uid: key, dictionary: value)
            completion(.success(user))
        }
    }

    /// username으로 사용자 조회합니다.
    func fetchUser(username: String, completion: @escaping (Result<UserModelProtocol, UserServiceError>) -> Void) {
        FirebasePath.usernames.child(username).observeSingleEvent(of: .value) { snapshot in
            guard let uid = snapshot.value as? String else {
                completion(.failure(.userNotFound))
                return
            }

            UserFactory.fetchUser(uid: uid) { result in
                switch result {
                case .success(let user): completion(.success(user))
                case .failure(let error):
                    print("❌ 유저 파싱 실패: \(error.localizedDescription)")
                    completion(.failure(.dataParsingError))
                }
            }
        }
    }

    // MARK: - 팔로우 관련 메서드

    /// 로그인 유저가 특정 유저를 팔로우합니다.
    func follow(uid: String, completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        FirebasePath.userFollowing.child(currentUid).updateChildValues([uid: 1]) { _, _ in
            FirebasePath.userFollowers.child(uid).updateChildValues([currentUid: 1]) { _, _ in
                FirebasePath.userTweets.child(uid).observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let self else { return }

                    if let children = snapshot.children.allObjects as? [DataSnapshot] {
                        for tweet in children {
                            let key = tweet.key
                            FirebasePath.userFeeds.child(currentUid).updateChildValues([key: 1])
                        }
                    }

                    notificationService.uploadNotification(type: .follow, toUid: uid)
                    completion()
                }
            }
        }
    }

    /// 언팔로우 처리합니다.
    func unFollow(uid: String, completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        FirebasePath.userFollowing.child(currentUid).child(uid).removeValue { _, _ in
            FirebasePath.userFollowers.child(uid).child(currentUid).removeValue { _, _ in
                FirebasePath.userTweets.child(uid).observeSingleEvent(of: .value) { snapshot in
                    if let children = snapshot.children.allObjects as? [DataSnapshot] {
                        for tweet in children {
                            let key = tweet.key
                            FirebasePath.userFeeds.child(currentUid).child(key).removeValue()
                            completion()
                        }
                    }
                }
            }
        }
    }

    /// 현재 로그인 유저가 해당 유저를 팔로우 중인지 확인합니다.
    func checkingFollow(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebasePath.userFollowing.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.hasChild(uid))
        }
    }

    /// 팔로워/팔로잉 수를 반환합니다.
    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void) {
        var followerCount = 0
        var followingCount = 0

        FirebasePath.userFollowers.child(uid).observe(.value) { snapshot in
            followerCount = (snapshot.value as? [String: Any])?.count ?? 0
            completion(followingCount, followerCount)
        }

        FirebasePath.userFollowing.child(uid).observe(.value) { snapshot in
            followingCount = (snapshot.value as? [String: Any])?.count ?? 0
            completion(followingCount, followerCount)
        }
    }

    // MARK: - 프로필 데이터 저장 및 이미지 업로드

    /// 유저의 이름/닉네임/소개글을 저장합니다.
    func saveUserData(fullName: String?, userName: String?, bio: String?, completion: @escaping ((Result<Void, Error>) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var values: [String: Any] = [:]
        if let fullName = fullName { values["fullName"] = fullName }
        if let userName = userName { values["userName"] = userName }
        if let bio = bio { values["bio"] = bio }

        FirebasePath.users.child(uid).updateChildValues(values) { error, _ in
            if let error = error {
                print("❌ 유저 데이터 저장 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    /// 프로필 이미지를 Firebase Storage에 업로드하고 URL을 반환합니다.
    func updateProfileImage(image: UIImage, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.3) else { return }

        let filename = UUID().uuidString

        FirebasePath.profileImages.child(filename).putData(imageData) { _, error in
            if let error = error {
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            FirebasePath.profileImages.child(filename).downloadURL { url, error in
                if let error = error {
                    print("❌ 이미지 URL 가져오기 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let profileImageUrl = url?.absoluteString else { return }
                let values = ["profileImageUrl": profileImageUrl]

                FirebasePath.users.child(uid).updateChildValues(values) { error, _ in
                    if let error = error {
                        print("❌ URL 저장 실패: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    completion(.success(profileImageUrl))
                }
            }
        }
    }
}
