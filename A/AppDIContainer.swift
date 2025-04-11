//
//  AppDIContainer.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
final class AppDIContainer {

    private lazy var authService = AuthService.shared

    func makeAuthService() -> AuthService {
        return authService
    }



    // MARK: - Repositories
    func makeAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepository(service: makeAuthService())
    }

    // MARK: - UseCases
    func makeSignUpUseCase() -> SignUpUseCaseProtocol {
        return SignUpUseCase(authRepository: makeAuthRepository())
    }

    func makeLoginUseCase() -> LoginUseCaseProtocol {
        return LoginUseCase(authRepository: makeAuthRepository())
    }

    func makeUserService() -> UserService {
        return UserService()
    }

    func makeUserRepository() -> UserRepositoryProtocol {
        return UserRepository(service: makeUserService())
    }

    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        return LogoutUseCase(authRepository: makeAuthRepository())
    }

    func makeRootNavigation(with nav: UINavigationController?) -> UINavigationController {
        return nav ?? UINavigationController()
    }


}
