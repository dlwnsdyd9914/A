//
//  AuthService.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase

class AuthService {
    typealias CompletionHandler = (Result<Void, AuthServiceError>) -> Void

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
            completion(.success(()))
        }
    }

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
}

