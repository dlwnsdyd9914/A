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

        UserFactory.fetchUser(uid: currentUid) { result  in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(.dataParsingError))
            }
        }
    }

    
}
