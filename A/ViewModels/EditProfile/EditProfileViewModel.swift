//
//  EditProfileViewModel.swift
//  A
//
//

import UIKit

/// 프로필 수정 화면의 전체 상태를 관리하는 뷰모델입니다.
/// - 역할: 사용자 프로필 정보의 수정 상태를 추적하고, 수정 요청을 처리합니다.
/// - 구성: 초기 상태 보관, 현재 상태 추적, 수정 여부 판단, 저장 요청 수행
final class EditProfileViewModel {

    // MARK: - Dependencies

    private let repository: UserRepositoryProtocol
    private let useCase: EditUseCaseProtocol

    // MARK: - 사용자 데이터 상태

    /// 현재 편집 중인 사용자 모델
    private(set) var user: UserModelProtocol

    /// 수정 가능한 프로필 옵션 (이름, 유저네임, 바이오)
    private(set) var editProfileOption = EditProfileOption.allCases

    /// 최초 로딩 시의 사용자 정보 (수정 여부 판단 기준)
    private let originalFullname: String
    private let originalUsername: String
    private let originalBio: String
    private let originalProfileImageUrl: String

    /// 현재 입력된 사용자 정보 (수정 중인 상태)
    var currentFullname: String
    var currentUsername: String
    var currentBio: String
    var currentProfileImage: UIImage?
    var currentProfileImageUrl: String

    // MARK: - Output Bindings (View에 전달)

    /// 저장 성공 시 호출
    var onSaveUserDataSuccess: (() -> Void)?

    /// 저장 실패 시 호출
    var onSaveUserDataFail: ((Error) -> Void)?

    /// 완료 버튼 활성화 여부 전달
    var onDoneButtonEnalbed: ((Bool) -> Void)?

    /// 사용자 정보 업데이트 후 뷰 갱신 트리거
    var onProfileUpadted: (() -> Void)?

    // MARK: - Initializer

    init(repository: UserRepositoryProtocol, user: UserModelProtocol, useCase: EditUseCaseProtocol) {
        self.repository = repository
        self.user = user
        self.useCase = useCase

        // 최초 상태 저장
        self.originalFullname = user.fullName
        self.originalUsername = user.userName
        self.originalBio = user.bio
        self.originalProfileImageUrl = user.profileImageUrl

        // 현재 상태 초기화
        self.currentFullname = user.fullName
        self.currentUsername = user.userName
        self.currentBio = user.bio
        self.currentProfileImageUrl = user.profileImageUrl
    }

    // MARK: - 상태 체크

    /// 수정사항이 존재하는지 여부를 판단
    var hasChanges: Bool {
        return originalFullname != currentFullname ||
               originalUsername != currentUsername ||
               originalBio != currentBio ||
               currentProfileImage != nil
    }

    /// 완료 버튼 상태를 업데이트
    func checkForChanges() {
        onDoneButtonEnalbed?(hasChanges)
    }

    // MARK: - 저장 요청

    /// 사용자 정보를 업데이트합니다.
    func updateUser() {
        useCase.editProfile(
            profileImage: currentProfileImage,
            fullName: currentFullname,
            userName: currentUsername,
            bio: currentBio,
            profileImageUrl: nil,
            currentUser: user
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.onSaveUserDataSuccess?()
            case .failure(let error):
                self.onSaveUserDataFail?(error)
            }
        }
    }
}
