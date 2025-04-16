//
//  AppDiConatinerProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

protocol AppDIContainerProtocol {

    // MARK: - Service Factories
    func makeAuthService() -> AuthService
    func makeUserService() -> UserService
    func makeTweetService() -> TweetService
    func makeNotificationService() -> NotificationService

    // MARK: - Repositories
    func makeAuthRepository() -> AuthRepositoryProtocol
    func makeUserRepository() -> UserRepositoryProtocol
    func makeTweetRepository() -> TweetRepositoryProtocol
    func makeNotificationRepository() -> NotificationRepositoryProtocol

    // MARK: - UseCases
    func makeSignUpUseCase() -> SignUpUseCaseProtocol
    func makeLoginUseCase() -> LoginUseCaseProtocol
    func makeLogoutUseCase() -> LogoutUseCaseProtocol
    func makeUploadTweetUseCase() -> UploadTweetUseCaseProtocol
    func makeFollowUseCase() -> FollowUseCaseProtocol
    func makeFetchTweetWithRepliesUseCase() -> FetchTweetWithRepliesUseCaseProtocol
    func makeTweetLikeUseCase() -> TweetLikeUseCaseProtocol
    func makeNotificationUseCase() -> NotificationUseCaseProtocol
    func makeProfileUseCase() -> ProfileUseCaseProtocol
    func makeEditUseCase() -> EditUseCaseProtocol

    // MARK: - Routers
    func makeAuthRouter() -> AuthRouterProtocol
    func makeUploadTweetRouter() -> UploadTweetRouterProtocol
    func makeMainTabBarRouter() -> MainTabBarRouterProtocol
    func makeFeedRouter() -> FeedRouterProtocol
    func makeExplorerRouter() -> ExplorerRouterProtocol
    func makeTweetRouter() -> TweetRouterProtocol
}
