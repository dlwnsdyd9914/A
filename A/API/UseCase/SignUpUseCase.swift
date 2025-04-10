//
//  SignUpUseCase.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class SignUpUseCase: SignUpUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        authRepository.signUp(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage, completion: completion) 
    }
}
