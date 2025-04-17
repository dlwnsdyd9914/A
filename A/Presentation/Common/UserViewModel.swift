//
//  UserViewModel.swift
//  A
//
//

import UIKit

/// 유저 정보를 관리하는 뷰모델
/// - 기능: 유저 기본 정보 접근, 팔로우 상태 확인 및 갱신
/// - 목적: 뷰 레이어가 직접 유저 모델에 접근하지 않도록 중간 계층 역할 수행
final class UserViewModel: UserViewModelProtocol {

    // MARK: - Dependencies

    /// 유저 팔로우/언팔로우 상태를 체크 및 변경하는 유즈케이스
    private let followUseCsae: FollowUseCaseProtocol

    /// 현재 바인딩 중인 유저 모델
    private var user: UserModelProtocol

    // MARK: - Initializer

    init(user: UserModelProtocol, followUseCase: FollowUseCaseProtocol) {
        self.user = user
        self.followUseCsae = followUseCase
        checkingFollow()
    }

    // MARK: - Output Properties

    /// 유저 이름 (예: @username)
    var username: String {
        return user.userName
    }

    /// 유저의 실명
    var fullname: String {
        return user.fullName
    }

    /// 유저의 UID
    var uid: String {
        return user.uid
    }

    /// 유저 프로필 이미지 URL
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }

    /// 유저 이메일
    var email: String {
        return user.email
    }

    /// 팔로우 여부
    var didFollow: Bool {
        get {
            return user.didFollow
        }
        set {
            user.didFollow = newValue
        }
    }

    // MARK: - Public Functions

    /// 바인딩된 유저 객체를 반환
    func getUser() -> UserModelProtocol {
        return user
    }

    /// 외부에서 팔로우 상태 수동 갱신
    func updateFollowState(_ followed: Bool) {
        user.didFollow = followed
    }

    /// 외부에서 유저 모델 전체 갱신
    func updateUserViewModel(user: UserModelProtocol) {
        self.user = user
    }

    // MARK: - Private Logic

    /// 서버로부터 현재 유저와의 팔로우 상태 확인
    private func checkingFollow() {
        followUseCsae.checkFollowStatus(uid: uid) { [weak self] didFollow in
            guard let self else { return }
            self.user.didFollow = didFollow
        }
    }
}

//
// MARK: - 프리뷰 및 테스트용 Mock 모델
//

/// Preview, Unit Test용 Mock 유저 데이터 모델
struct MockUserModel: UserModelProtocol {

    func applyEdit(fullName: String?, userName: String?, bio: String?, profileImageUrl: String?) {
        // ⚠️ Preview용으로 실제 구현은 비워둠
    }

    var bio: String

    var userFollowingCount: Int = 0
    var userFollowerCount: Int = 1
    var isCurrentUser: Bool = true
    var didFollow: Bool = false
    var email: String = "preview@example.com"
    var userName: String = "PreviewUser"
    var fullName: String = "Preview Full Name"
    var profileImageUrl: String = "https://via.placeholder.com/150"
    var uid: String = "previewUID"
}
