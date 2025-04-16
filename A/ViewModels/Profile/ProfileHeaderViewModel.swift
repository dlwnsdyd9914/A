//
//  ProfileHeaderViewModel.swift
//  A
//
//

import UIKit

/// 프로필 화면의 상단 뷰에서 사용하는 뷰모델입니다.
/// - 사용자 정보 렌더링, 팔로우/언팔로우 로직 처리, 프로필 수정 트리거 기능을 제공합니다.
final class ProfileHeaderViewModel: ProfileHeaderViewModelProtocol {

    // MARK: - Properties

    /// 현재 표시할 유저 정보
    private var user: UserModelProtocol

    /// 유저 관련 네트워크 처리 레포지토리
    private let repository: UserRepositoryProtocol

    /// 팔로우/언팔로우 관련 유즈케이스
    private let useCase: FollowUseCaseProtocol

    // MARK: - Initializer

    init(user: UserModelProtocol, repository: UserRepositoryProtocol, useCase: FollowUseCaseProtocol) {
        self.user = user
        self.repository = repository
        self.useCase = useCase
    }

    // MARK: - Output Properties

    /// 팔로워 수 텍스트 (ex: "20 followers")
    var followerString: NSAttributedString {
        return followAttributedText(value: user.userFollowerCount, text: "follwer")
    }

    /// 팔로잉 수 텍스트 (ex: "10 following")
    var followingString: NSAttributedString {
        return followAttributedText(value: user.userFollowingCount, text: "following")
    }

    /// 프로필 이미지 URL
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }

    /// 사용자 정보 (이름 + 유저네임)
    var infoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.userName)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                   NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    /// 프로필 우측 상단 액션 버튼 텍스트
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        } else {
            return didFollow ? "Following" : "Follow"
        }
    }

    /// 사용자 이름
    var fullname: String {
        return user.fullName
    }

    /// 유저네임
    var username: String {
        return user.userName
    }

    /// 사용자 고유 ID
    var uid: String {
        return user.uid
    }

    /// 현재 사용자와의 팔로우 상태
    var didFollow: Bool {
        get { return user.didFollow }
        set { user.didFollow = newValue }
    }

    /// 사용자 자기소개 텍스트
    var bio: String {
        get { return user.bio }
        set { user.bio = newValue }
    }

    /// 외부에서 유저 객체를 필요로 할 경우 반환
    func getUser() -> UserModelProtocol {
        return user
    }

    // MARK: - Callbacks

    /// 팔로우 상태 변경 시 콜백
    var onFollowToggled: (() -> Void)?

    /// 팔로우 상태 초기 체크 후 텍스트 갱신 콜백
    var onFollowStatusCheck: ((String) -> Void)?

    /// 팔로워/팔로잉 수 업데이트 콜백
    var onFollowLabelCount: (() -> Void)?

    /// 현재 유저일 경우 'Edit Profile' 진입 콜백
    var onEditProfileTapped: (() -> Void)?

    // MARK: - Business Logic

    /// 팔로우 텍스트를 포맷팅하여 반환합니다 (ex: "1 followers")
    func followAttributedText(value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedText
    }

    /// 액션 버튼 탭 시 로직 처리
    /// - 본인인 경우 프로필 수정
    /// - 타인인 경우 팔로우/언팔로우 처리
    func followToggled() {
        if user.isCurrentUser {
            onEditProfileTapped?()
            return
        }

        useCase.toggleFollow(didFollow: didFollow, uid: uid) { [weak self] in
            guard let self else { return }
            self.user.didFollow.toggle()
            self.onFollowToggled?()
        }
    }

    /// 현재 유저가 팔로우 중인지 체크하여 UI에 반영
    func checkingFollow() {
        useCase.checkFollowStatus(uid: uid) { [weak self] followStatus in
            guard let self else { return }
            self.user.didFollow = followStatus
            self.onFollowStatusCheck?(followStatus ? "Following" : "Follow")
        }
    }

    /// 팔로워 / 팔로잉 수를 네트워크로 받아와 뷰 갱신
    func getFollowCount() {
        useCase.getFollowCounts(uid: uid) { [weak self] following, follower in
            guard let self else { return }
            self.user.userFollowingCount = following
            self.user.userFollowerCount = follower
            self.onFollowLabelCount?()
        }
    }

    /// 외부에서 명시적으로 버튼 탭을 유도할 경우 사용
    func handleEditFollowButtonTapped() {
        followToggled()
    }
}
