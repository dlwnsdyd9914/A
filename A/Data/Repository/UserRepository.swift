//
//  UserRepository.swift
//  A
//
//

import UIKit

/// 사용자 관련 기능을 추상화한 Repository 클래스입니다.
///
/// - 역할:
///     - `UserService`를 통해 사용자 데이터에 대한 CRUD 작업을 수행합니다.
///     - 유저 프로필, 팔로우 상태, 사용자 리스트 등의 기능을 외부 도메인 계층에서 접근 가능하게 추상화합니다.
///
/// - 주요 사용처:
///     - `UserViewModel`, `ProfileHeaderViewModel`, `ExplorerViewModel`, `EditProfileViewModel` 등 사용자 데이터에 의존하는 ViewModel
///
/// - 설계 이유:
///     - Firebase에 직접 접근하지 않고, 서비스 계층과 도메인 계층을 분리하여 SRP 유지 및 테스트 유연성 확보
final class UserRepository: UserRepositoryProtocol {

    // MARK: - Dependencies

    private let service: UserService

    // MARK: - Initializer

    init(service: UserService) {
        self.service = service
    }

    // MARK: - Current User

    /// 현재 로그인된 사용자 정보를 조회합니다.
    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.getCurrentUser(completion: completion)
    }

    // MARK: - User List

    /// 전체 유저 목록을 가져옵니다.
    func fetchAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.getAllUserList(completion: completion)
    }

    // MARK: - Follow

    /// 지정된 사용자를 팔로우합니다.
    func follow(uid: String, completion: @escaping () -> Void) {
        service.follow(uid: uid, completion: completion)
    }

    /// 지정된 사용자를 언팔로우합니다.
    func unfollow(uid: String, completion: @escaping () -> Void) {
        service.unFollow(uid: uid, completion: completion)
    }

    /// 현재 로그인 유저가 특정 UID를 팔로우 중인지 확인합니다.
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {
        service.checkingFollow(uid: uid, completion: completion)
    }

    /// 팔로잉/팔로워 수를 조회합니다.
    func getFollowCount(uid: String, completion: @escaping (Int, Int) -> Void) {
        service.getFollowCount(uid: uid, completion: completion)
    }

    // MARK: - Selected User

    /// 특정 UID에 해당하는 유저 정보를 조회합니다.
    func fetchSelectedUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.fetchSelectedUser(uid: uid, completion: completion)
    }

    /// 특정 username으로 유저 정보를 조회합니다.
    func fetchUser(username: String, completion: @escaping (Result<UserModelProtocol, UserServiceError>) -> Void) {
        service.fetchUser(username: username, completion: completion)
    }

    // MARK: - Profile Editing

    /// 유저 이름/닉네임/소개 등을 저장합니다.
    func saveUserData(fullName: String, userName: String, bio: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        service.saveUserData(fullName: fullName, userName: userName, bio: bio, completion: completion)
    }

    /// 유저 프로필 이미지를 업데이트합니다.
    func updateProfileImage(image: UIImage, completion: @escaping ((Result<String, Error>) -> Void)) {
        service.updateProfileImage(image: image, completion: completion)
    }
}
