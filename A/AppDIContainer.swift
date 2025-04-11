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

    func makeTweetService() -> TweetService {
        return TweetService()
    }



    // MARK: - Repositories
    func makeAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepository(service: makeAuthService())
    }

    func makeTweetRepository() -> TweetRepositoryProtocol {
        return TweetRepository(service: makeTweetService())
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

    func makeUploadTweetUseCase() -> UploadTweetUseCaseProtocol {
        return UploadTweetUseCase(tweetRepository: makeTweetRepository())
    }

    func makeRootNavigation(with nav: UINavigationController?) -> UINavigationController {
        return nav ?? UINavigationController()
    }


}
