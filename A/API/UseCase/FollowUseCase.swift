//
//  FollowUseCase.swift
//  A
//
//

import UIKit

/// 팔로우 관련 기능을 처리하는 유즈케이스입니다.
///
/// - 역할:
///     - 팔로우/언팔로우, 팔로우 상태 확인, 팔로워/팔로잉 수 조회 등 비즈니스 로직을 담당합니다.
///     - 실제 네트워크 작업은 `UserRepositoryProtocol`에 위임합니다.
///
/// - 주요 사용처:
///     - `UserViewModel`, `ProfileHeaderViewModel`, `NotificationCellViewModel` 등에서
///       팔로우 상태 변경 및 상태 조회 시 호출됩니다.
///
/// - 비즈니스 목적:
///     - 뷰모델에서 직접 레포지토리 접근을 막고, 명확한 책임 분리를 통해 아키텍처를 개선합니다.
final class FollowUseCase: FollowUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: UserRepositoryProtocol

    // MARK: - Initializer

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// 유저를 팔로우합니다.
    /// - Parameters:
    ///   - uid: 팔로우 대상 유저의 UID
    ///   - completion: 완료 핸들러
    func follow(uid: String, completion: @escaping () -> Void) {
        repository.follow(uid: uid, completion: completion)
    }

    /// 유저를 언팔로우합니다.
    /// - Parameters:
    ///   - uid: 언팔로우 대상 유저의 UID
    ///   - completion: 완료 핸들러
    func unfollow(uid: String, completion: @escaping () -> Void) {
        repository.unfollow(uid: uid, completion: completion)
    }

    /// 특정 유저에 대해 팔로우 여부를 확인합니다.
    /// - Parameters:
    ///   - uid: 확인할 대상 유저의 UID
    ///   - completion: 팔로우 상태 (true/false)
    func checkFollowStatus(uid: String, completion: @escaping (Bool) -> Void) {
        repository.checkFollowStatus(uid: uid, completion: completion)
    }

    /// 특정 유저의 팔로잉/팔로워 수를 조회합니다.
    /// - Parameters:
    ///   - uid: 대상 유저 UID
    ///   - completion: (팔로잉 수, 팔로워 수)
    func getFollowCounts(uid: String, completion: @escaping (Int, Int) -> Void) {
        repository.getFollowCount(uid: uid, completion: completion)
    }

    /// 팔로우 상태를 토글합니다.
    /// - Parameters:
    ///   - didFollow: 현재 팔로우 상태
    ///   - uid: 대상 유저 UID
    ///   - completion: 완료 핸들러
    func toggleFollow(didFollow: Bool, uid: String, completion: @escaping () -> Void) {
        didFollow ? unfollow(uid: uid, completion: completion)
                  : follow(uid: uid, completion: completion)
    }
}
