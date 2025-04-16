//
//  AuthService.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase

/// Firebase Auth 기반의 인증 처리를 담당하는 서비스 클래스입니다.
///
/// - 역할:
///     - 회원가입, 로그인, 로그아웃과 같은 인증 기능을 제공합니다.
///     - 프로필 이미지 저장 및 사용자 정보 Firebase Database에 등록합니다.
///
/// - 주요 사용처:
///     - `AuthRepository`, `SignUpUseCase`, `LoginUseCase`, `LogoutUseCase` 등 UseCase 레벨에서 호출
///
/// - 설계 이유:
///     - 인증 관련 Firebase 처리 로직을 SRP 원칙에 따라 분리하여 유지보수 용이성을 확보하고,
///       재사용 가능한 구조로 설계함
class AuthService {

    typealias CompletionHandler = (Result<Void, AuthServiceError>) -> Void

    static let shared = AuthService()
    private init() {}

    /// 현재 로그인 여부 확인
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    // MARK: - Public Methods

    /// Firebase 이메일/비밀번호 회원가입 처리 및 프로필 이미지 업로드, 사용자 정보 저장
    func createUser(email: String, password: String, profileImage: UIImage, username: String, fullname: String, completion: @escaping CompletionHandler) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("가입 실패:", error.localizedDescription)
                completion(.failure(.failedToCreateUser))
                return
            }

            print("가입 성공")
            self.saveProfileImage(email: email, profileImage: profileImage, username: username, fullname: fullname, completion: completion)
        }
    }

    /// 로그인 처리 함수
    func login(email: String, password: String, completion: @escaping CompletionHandler) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ 로그인 실패:", error.localizedDescription)
                completion(.failure(.faildToLogin))
                return
            }
            print("✅ 로그인 성공")
            completion(.success(()))
        }
    }

    /// 로그아웃 처리 함수
    /// - Parameter completion: 결과 콜백
    func logout(completion: @escaping CompletionHandler) {
        do {
            try Auth.auth().signOut()
            print("✅ 로그아웃 성공")
            completion(.success(()))
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
            completion(.failure(.faildToLogout))
        }
    }

    // MARK: - Private Methods

    /// 파이어베이스 스토리지에 프로필 이미지 저장
    private func saveProfileImage(email: String, profileImage: UIImage, username: String, fullname: String, completion: @escaping CompletionHandler) {
        let filename = UUID().uuidString

        guard let data = profileImage.jpegData(compressionQuality: 0.3) else {
            completion(.failure(.invalidImageData))
            return
        }

        FirebasePath.profileImages.child(filename).putData(data) { [weak self] metadata, error in
            guard let self = self else { return }

            if let error = error {
                print("프로필 이미지 저장 실패:", error.localizedDescription)
                completion(.failure(.failedToUploadImage))
                return
            }

            print("프로필 이미지 저장 성공")
            self.downloadProfileImage(email: email, filename: filename, username: username, fullname: fullname, completion: completion)
        }
    }

    /// 스토리지에 저장된 프로필 이미지 다운로드 URL 획득
    private func downloadProfileImage(email: String, filename: String, username: String, fullname: String, completion: @escaping CompletionHandler) {
        FirebasePath.profileImages.child(filename).downloadURL { [weak self] url, error in
            guard let self = self else { return }

            if let error = error {
                print("프로필 이미지 다운로드 실패:", error.localizedDescription)
                completion(.failure(.failedToGetImageURL))
                return
            }

            guard let profileImageUrl = url?.absoluteString else {
                completion(.failure(.failedToGetImageURL))
                return
            }

            print("프로필 이미지 다운로드 성공: \(profileImageUrl)")
            self.saveDatabase(email: email, profileImageUrl: profileImageUrl, fullname: fullname, username: username, completion: completion)
        }
    }

    /// Firebase Database에 유저 정보 저장
    private func saveDatabase(email: String, profileImageUrl: String, fullname: String, username: String, completion: @escaping CompletionHandler) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(.failure(.failedToSaveUserData))
            return
        }

        let values: [String: Any] = [
            "email": email,
            "uid": currentUid,
            "profileImageUrl": profileImageUrl,
            "userName": username,
            "fullName": fullname
        ]

        FirebasePath.users.child(currentUid).updateChildValues(values) { error, _ in
            if let error = error {
                print("디비 저장 실패:", error.localizedDescription)
                completion(.failure(.failedToSaveUserData))
                return
            }

            print("디비 저장 성공")
            let lowercasedUsername = username.lowercased()
            FirebasePath.usernames.child(lowercasedUsername).setValue(currentUid)
            completion(.success(()))
        }
    }
}
