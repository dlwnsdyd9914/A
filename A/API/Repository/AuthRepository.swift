//
//  AuthRepository.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//
import UIKit

final class AuthRepository: AuthRepositoryProtocol {

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }


    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.createUser(email: email, password: password, profileImage: profileImage, username: username, fullname: fullname, completion: completion)
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.login(email: email, password: password, completion: completion)
    }

    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.logout(completion: completion)
    }
}
