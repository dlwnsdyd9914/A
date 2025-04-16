//
//  ExplorerRouter.swift
//  A
//
//

import UIKit

/// 유저 탐색(Explore) 화면에서의 라우팅을 담당하는 클래스입니다.
///
/// - 역할:
///     - Explore 탭에서 선택된 유저의 프로필로 이동
///
/// - 주요 사용처:
///     - ExplorerController 내 사용자 인터랙션 발생 시 호출됨
///
/// - 설계 이유:
///     - 화면 전환 책임을 라우터로 분리함으로써 컨트롤러의 SRP(단일 책임 원칙)를 유지
///     - 종속된 라우터, UseCase, Repository 등을 통해 뷰 생성 시 필요한 의존성들을 DI 방식으로 주입
final class ExplorerRouter: ExplorerRouterProtocol {

    // MARK: - Dependencies

    private let mainTabRouter: MainTabBarRouterProtocol
    private let feedRouter: FeedRouterProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let tweetRepostiory: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let profileUseCase: ProfileUseCaseProtocol
    private let userRepository: UserRepositoryProtocol
    private let editUseCase: EditUseCaseProtocol

    // MARK: - Initializer

    init(mainTabRouter: MainTabBarRouterProtocol, feedRouter: FeedRouterProtocol, tweetRepostiory: TweetRepositoryProtocol, followUseCase: FollowUseCaseProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, profileUseCase: ProfileUseCaseProtocol, userRepository: UserRepositoryProtocol, editUseCase: EditUseCaseProtocol) {
        self.mainTabRouter = mainTabRouter
        self.feedRouter = feedRouter
        self.tweetRepostiory = tweetRepostiory
        self.followUseCase = followUseCase
        self.tweetLikeUseCase = tweetLikeUseCase
        self.profileUseCase = profileUseCase
        self.userRepository = userRepository
        self.editUseCase = editUseCase
    }

    // MARK: - Navigation

    /// 유저 프로필 화면으로 이동합니다.
    /// - Parameters:
    ///   - user: 선택된 유저 모델
    ///   - viewController: 현재 탐색 화면 뷰컨트롤러
    func navigateToUserProfile(user: UserModelProtocol, from viewController: UIViewController) {
        let userViewModel = UserViewModel(user: user, followUseCase: followUseCase)
        let profileController = ProfileController(router: mainTabRouter, userViewModel: userViewModel, useCase: profileUseCase, followUseCase: followUseCase, feedRouter: feedRouter, tweetLikeUseCase: tweetLikeUseCase, tweetRepository: tweetRepostiory, userRepository: userRepository, editUseCase: editUseCase)
        viewController.navigationController?.pushViewController(profileController, animated: true)
    }
}
