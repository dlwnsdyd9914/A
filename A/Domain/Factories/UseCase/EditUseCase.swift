//
//  EditUseCase.swift
//  A
//
//  Created by 이준용 on 4/16/25.
//

import UIKit
import Firebase

/// 사용자 프로필 정보를 수정하는 유즈케이스입니다.
///
/// - 역할: 전체 프로필 수정 요청을 받아, 이미지 포함 여부에 따라 내부 로직을 분기 처리합니다.
/// - 주요 사용처:
///     - `EditProfileViewModel`: 사용자 정보 저장 시 호출됨
/// - 핵심 설계 의도:
///     - 이미지가 있는 경우와 없는 경우를 명확히 분기하여, 이미지 업로드 로직과 사용자 정보 저장 로직을 효율적으로 분리
final class EditUseCase: EditUseCaseProtocol {

    // MARK: - Properties

    private let repository: UserRepositoryProtocol

    // MARK: - Initializer

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Functions

    /// 프로필 전체 수정 처리 함수입니다. (이미지 포함 여부에 따라 분기 처리)
    ///
    /// - Parameters:
    ///   - profileImage: 새 프로필 이미지 (없을 수 있음)
    ///   - fullName: 변경할 이름
    ///   - userName: 변경할 유저네임
    ///   - bio: 변경할 바이오
    ///   - profileImageUrl: 기존 이미지 URL (이미지 변경 없을 경우 사용)
    ///   - currentUser: 수정 대상 유저
    ///   - completion: 업로드 성공 시 새 이미지 URL 반환, 실패 시 Error 반환
    func editProfile(profileImage: UIImage?,fullName: String?,userName: String?,bio: String?,profileImageUrl: String?,currentUser: UserModelProtocol,completion: @escaping ((Result<String?, Error>) -> Void)
    ) {
        // ✅ 기본 정보 준비 - 변경값이 없다면 기존 값 유지
        var updatedFullName = currentUser.fullName
        var updatedUserName = currentUser.userName
        var updatedBio = currentUser.bio

        if let newFullName = fullName { updatedFullName = newFullName }
        if let newUserName = userName { updatedUserName = newUserName }
        if let newBio = bio { updatedBio = newBio }

        // ✅ 사용자 기본 정보 저장
        repository.saveUserData(fullName: updatedFullName, userName: updatedUserName, bio: updatedBio) { [weak self] _ in
            guard let self else { return }

            // ✅ 이미지가 있을 경우: 이미지 업로드 + 저장된 URL 반환
            if let profileImage = profileImage {
                self.repository.updateProfileImage(image: profileImage) { result in
                    switch result {
                    case .success(let uploadedUrl):
                        currentUser.applyEdit(fullName: updatedFullName, userName: updatedUserName, bio: updatedBio, profileImageUrl: uploadedUrl)
                        completion(.success(uploadedUrl))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                // ✅ 이미지 변경 없음: 기존 URL 그대로 사용
                currentUser.applyEdit(fullName: updatedFullName, userName: updatedUserName, bio: updatedBio, profileImageUrl: currentUser.profileImageUrl)
                completion(.success(currentUser.profileImageUrl))
            }
        }
    }

    // MARK: - Private Functions

    /// 내부에서만 사용되는 텍스트 기반 프로필 수정 처리 로직
    ///
    /// - Parameters:
    ///   - fullName, userName, bio: 사용자 기본 정보
    ///   - profileImageUrl: 기존 이미지 URL
    ///   - currentUser: 수정 대상 유저
    ///   - completion: 저장 성공/실패 반환
    ///
    /// - 사용 이유:
    ///     - `editProfile` 내에서 이미지가 없을 경우, 이 함수를 호출해 분리된 텍스트 처리만 수행
    private func editProfileInfo(fullName: String, userName: String, bio: String, profileImageUrl: String?, currentUser: UserModelProtocol, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        repository.saveUserData(fullName: fullName, userName: userName, bio: bio) { result in
            switch result {
            case .success():
                currentUser.applyEdit(fullName: fullName, userName: userName, bio: bio, profileImageUrl: profileImageUrl)
                completion(.success(()))
            case .failure(let error):
                print("❌ 유저 저장 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
