//
//  UserFactory.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Firebase

struct UserFactory {

    static func fetchUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        FirebasePath.users.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }

            let user = User(uid: snapshot.key, dictionary: value)
            completion(.success(user))
        }
    }
}
