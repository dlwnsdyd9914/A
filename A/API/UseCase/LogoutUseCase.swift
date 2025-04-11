//
//  LogoutUseCase.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        self.authRepository.logout(completion: completion)
    }
    

}
