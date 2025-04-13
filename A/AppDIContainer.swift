//
//  AppDIContainer.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class AppDIContainer: AppDIContainerProtocol {

    // MARK: - Services (싱글톤 또는 재사용 가능한 인스턴스)

    private lazy var authService = AuthService.shared
    private lazy var userService = UserService()
    private lazy var tweetService = TweetService()
    private lazy var notificationService = NotificationService()

    // MARK: - Routers (필요 시 한 번만 생성)

    private lazy var mainTabRouter: MainTabBarRouterProtocol = {
        return MainTabRouter(loginUseCase: makeLoginUseCase())
    }()

    // MARK: - Services Factory

    func makeAuthService() -> AuthService { authService }
    func makeUserService() -> UserService { userService }
    func makeTweetService() -> TweetService { tweetService }
    func makeNotificationService() -> NotificationService { notificationService }

    // MARK: - Repositories

    func makeAuthRepository() -> AuthRepositoryProtocol {
        AuthRepository(service: makeAuthService())
    }

    func makeTweetRepository() -> TweetRepositoryProtocol {
        TweetRepository(service: makeTweetService())
    }

    func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository(service: makeUserService())
    }

    func makeNotificationRepository() -> NotificationRepositoryProtocol {
        NotificationRepository(service: makeNotificationService())
    }

    // MARK: - UseCases

    func makeSignUpUseCase() -> SignUpUseCaseProtocol {
        SignUpUseCase(authRepository: makeAuthRepository())
    }

    func makeLoginUseCase() -> LoginUseCaseProtocol {
        LoginUseCase(authRepository: makeAuthRepository())
    }

    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        LogoutUseCase(authRepository: makeAuthRepository())
    }

    func makeUploadTweetUseCase() -> UploadTweetUseCaseProtocol {
        UploadTweetUseCase(tweetRepository: makeTweetRepository())
    }

    func makeFollowUseCase() -> FollowUseCaseProtocol {
        FollowUseCase(repository: makeUserRepository())
    }

    func makeFetchTweetWithRepliesUseCase() -> FetchTweetWithRepliesUseCaseProtocol {
        FetchTweetWithRepliesUseCase(repository: makeTweetRepository())
    }

    func makeTweetLikeUseCase() -> TweetLikeUseCaseProtocol {
        TweetLikeUseCase(repository: makeTweetRepository())
    }

    func makeNotificationUseCase() -> NotificationUseCaseProtocol {
        NotificationUseCase(repository: makeNotificationRepository(), userRepository: makeUserRepository(), tweetRepository: makeTweetRepository())
    }

    // MARK: - Routers

    func makeAuthRouter() -> AuthRouterProtocol {
        return AuthRouter(
            userRepository: makeUserRepository(),
            explorerRouter: makeExplorerRouter(),
            signUpUseCase: makeSignUpUseCase(),
            logoutUseCase: makeLogoutUseCase(),
            tweetReposiotry: makeTweetRepository(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            notificationUseCase: makeNotificationUseCase()
        )
    }

    func makeUploadTweetRouter() -> UploadTweetRouterProtocol {
        UploadTweetRouter(uploadTweetUseCase: makeUploadTweetUseCase())
    }

    func makeMainTabBarRouter() -> MainTabBarRouterProtocol {
        mainTabRouter
    }

    func makeFeedRouter() -> FeedRouterProtocol {
        FeedRouter(
            mainTabRouter: makeMainTabBarRouter(),
            tweetRepository: makeTweetRepository(),
            tweetRouter: makeTweetRouter(),
            uploadTweetRouter: makeUploadTweetRouter(),
            followUseCase: makeFollowUseCase(),
            tweetLikeUseCase: makeTweetLikeUseCase()
        )
    }

    func makeExplorerRouter() -> ExplorerRouterProtocol {
        ExplorerRouter(
            mainTabRouter: makeMainTabBarRouter(),
            feedRouter: makeFeedRouter(),
            tweetRepostiory: makeTweetRepository(),
            followUseCase: makeFollowUseCase(),
            tweetLikeUseCase: makeTweetLikeUseCase()
        )
    }

    func makeTweetRouter() -> TweetRouterProtocol {
        TweetRouter(
            tweetRepository: makeTweetRepository(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            followUseCase: makeFollowUseCase()
        )
    }
}
