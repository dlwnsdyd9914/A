//
//  AppDIContainer.swift
//  A
//

//

import UIKit

/// 앱 전역에서 의존성 주입을 담당하는 DI 컨테이너입니다.
///
/// - 역할:
///     - 서비스, 리포지토리, 유즈케이스, 라우터 객체를 생성 및 관리
///     - 객체 간 의존성을 해소하고 주입 방식 통일
///
/// - 주요 사용처:
///     - SceneDelegate 또는 AppCoordinator 등 앱 진입 지점에서 객체 생성 시 사용
///     - 라우터 및 컨트롤러 생성 시 의존성 주입에 활용
///
/// - 설계 이유:
///     - DIContainer를 통해 의존성 분리를 명확히 하여 테스트 용이성 및 유지보수성 향상
///     - 중복 객체 생성을 피하고 전역적으로 통일된 인스턴스 사용을 보장
final class AppDIContainer: AppDIContainerProtocol {

    // MARK: - Services (싱글톤 또는 재사용 가능한 인스턴스)

    private lazy var authService = AuthService.shared
    private lazy var userService = UserService()
    private lazy var tweetService = TweetService()
    private lazy var notificationService = NotificationService()

    // MARK: - 라우터 (한 번만 생성)

    private lazy var mainTabRouter: MainTabBarRouterProtocol = {
        return MainTabRouter(loginUseCase: makeLoginUseCase())
    }()

    // MARK: - Service Factory

    func makeAuthService() -> AuthService { authService }
    func makeUserService() -> UserService { userService }
    func makeTweetService() -> TweetService { tweetService }
    func makeNotificationService() -> NotificationService { notificationService }

    // MARK: - Repository Factory

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

    // MARK: - UseCase Factory

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
        NotificationUseCase(
            repository: makeNotificationRepository(),
            userRepository: makeUserRepository(),
            tweetRepository: makeTweetRepository()
        )
    }

    func makeProfileUseCase() -> ProfileUseCaseProtocol {
        ProfileUseCase(repository: makeTweetRepository())
    }

    func makeEditUseCase() -> EditUseCaseProtocol {
        EditUseCase(repository: makeUserRepository())
    }

    // MARK: - Router Factory

    func makeAuthRouter() -> AuthRouterProtocol {
        AuthRouter(
            userRepository: makeUserRepository(),
            explorerRouter: makeExplorerRouter(),
            signUpUseCase: makeSignUpUseCase(),
            logoutUseCase: makeLogoutUseCase(),
            tweetReposiotry: makeTweetRepository(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            notificationUseCase: makeNotificationUseCase(),
            followUseCase: makeFollowUseCase()
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
            uploadTweetRouter: makeUploadTweetRouter(),
            followUseCase: makeFollowUseCase(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            profileUseCase: makeProfileUseCase(),
            userRepository: makeUserRepository(),
            editUseCase: makeEditUseCase()
        )
    }

    func makeExplorerRouter() -> ExplorerRouterProtocol {
        ExplorerRouter(
            mainTabRouter: makeMainTabBarRouter(),
            feedRouter: makeFeedRouter(),
            tweetRepostiory: makeTweetRepository(),
            followUseCase: makeFollowUseCase(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            profileUseCase: makeProfileUseCase(),
            userRepository: makeUserRepository(),
            editUseCase: makeEditUseCase()
        )
    }

    func makeTweetRouter() -> TweetRouterProtocol {
        TweetRouter(
            tweetRepository: makeTweetRepository(),
            tweetLikeUseCase: makeTweetLikeUseCase(),
            followUseCase: makeFollowUseCase(),
            feedRouter: makeFeedRouter(),
            userRepository: makeUserRepository()
        )
    }
}
