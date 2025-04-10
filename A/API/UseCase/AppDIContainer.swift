//
//  AppDIContainer.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
final class AppDIContainer {

    // MARK: - Services
    func makeAuthService() -> AuthService {
        return AuthService()
    }

    // MARK: - Repositories
    func makeAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepository(service: makeAuthService())
    }

    // MARK: - UseCases
    func makeSignUpUseCase() -> SignUpUseCase {
        return SignUpUseCase(authRepository: makeAuthRepository())
    }

    func makeLoginUseCase() -> LoginUseCase {
        return LoginUseCase(authRepository: makeAuthRepository())
    }

    func makeUserService() -> UserService {
        return UserService()
    }

    func makeUserRepository() -> UserRepository {
        return UserRepository(service: makeUserService())
    }

}
