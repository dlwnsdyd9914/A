//
//  UserRepository.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class UserRepository: UserRepositoryProtocol {


    private let service: UserService

    init(service: UserService) {
        self.service = service
    }

    func fetchUser(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        service.getCurrentUser(completion: completion)
    }
    

}
