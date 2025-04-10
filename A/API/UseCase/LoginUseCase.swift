//
//  LoginUseCase.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class LoginUseCase: LoginUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        authRepository.login(email: email, password: password, completion: completion)
    }


}
