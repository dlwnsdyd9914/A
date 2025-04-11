//
//  UserService.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase

class UserService {

    typealias CompletionHandler = (Result<User, UserServiceError>) -> Void

    func getCurrentUser(completion: @escaping CompletionHandler) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        fetchUser(uid: currentUid) {result in

            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    //팩토리 함수

    private func fetchUser(uid: String, completion: @escaping CompletionHandler) {
        FirebasePath.users.child(uid).observeSingleEvent(of: .value) { snapshot in

            let key = snapshot.key

            guard let value = snapshot.value as? [String: Any] else {
                print("❗️데이터 파싱 에러 스냅샷 밸류 데이터 없음.")
                completion(.failure(.dataParsingError))
                return
            }

            let user = User(uid: key, dictionary: value)
            completion(.success(user))
        }
    }
}
