//
//  NotificationRouter.swift
//  A
//
//

import UIKit

/// 알림 화면에서 발생하는 라우팅을 담당하는 라우터입니다.
///
/// - 역할:
///     - 알림(Notification) 리스트에서 사용자 프로필 또는 트윗 상세화면으로의 화면 전환 처리
///     - DI된 의존성을 활용해 각 화면을 생성하고, 현재 뷰컨트롤러에서 네비게이션 push 수행
///
/// - 주요 사용처:
///     - `NotificationController` 또는 관련 ViewModel 내에서 화면 이동 요청 시 사용됨
///
/// - 설계 이유:
///     - 화면 전환 로직을 뷰컨트롤러에서 분리하여, 테스트 가능하고 책임이 명확한 구조로 구성
///     - 의존성 주입(DI)을 통해 재사용성 및 확장성 확보
final class NotificationRouter: NotificationRouterProtocol {

    // MARK: - Dependencies

    private let mainTabRouter: MainTabBarRouterProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let feedRouter: FeedRouterProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let tweetRouter: TweetRouterProtocol
    private let profileUseCase: ProfileUseCaseProtocol
    private let userRepository: UserRepositoryProtocol
    private let editUseCase: EditUseCaseProtocol

    // MARK: - Initializer

    init(mainTabRouter: MainTabBarRouterProtocol, tweetRepository: TweetRepositoryProtocol, followUseCase: FollowUseCaseProtocol, feedRouter: FeedRouterProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, tweetRouter: TweetRouter, profileUseCase: ProfileUseCaseProtocol, userRepository: UserRepositoryProtocol, editUseCase: EditUseCaseProtocol) {
        self.mainTabRouter = mainTabRouter
        self.tweetRepository = tweetRepository
        self.followUseCase = followUseCase
        self.feedRouter = feedRouter
        self.tweetLikeUseCase = tweetLikeUseCase
        self.tweetRouter = tweetRouter
        self.profileUseCase = profileUseCase
        self.userRepository = userRepository
        self.editUseCase = editUseCase
    }

    // MARK: - Routing Logic

    /// 알림에서 발생한 목적지로 화면 이동을 수행합니다.
    /// - Parameters:
    ///   - destination: 목적지 enum (.userProfile, .tweetDetail)
    ///   - viewController: 현재 기준이 되는 뷰컨트롤러 (화면 전환 기준점)
    func navigate(to destination: NotificationDestination, from viewController: UIViewController) {
        switch destination {

        case .userProfile(let userViewModel):
            /// 유저 프로필 화면으로 이동
            let profileController = ProfileController(
                router: mainTabRouter,
                userViewModel: userViewModel,
                useCase: profileUseCase,
                followUseCase: followUseCase,
                feedRouter: feedRouter,
                tweetLikeUseCase: tweetLikeUseCase,
                tweetRepository: tweetRepository,
                userRepository: userRepository,
                editUseCase: editUseCase
            )
            viewController.navigationController?.pushViewController(profileController, animated: true)

        case .tweetDetail(let tweetViewModel, let userViewModel):
            /// 트윗 상세화면으로 이동
            let tweetController = TweetController(
                viewModel: tweetViewModel,
                repository: tweetRepository,
                router: tweetRouter,
                useCase: tweetLikeUseCase,
                followUseCase: followUseCase,
                userViewModel: userViewModel,
                userRepository: userRepository
            )
            viewController.navigationController?.pushViewController(tweetController, animated: true)
        }
    }
}
