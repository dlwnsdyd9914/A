//
//  AuthRouter.swift
//  A
//
//

import UIKit

/// 로그인 및 회원가입 흐름의 화면 전환을 담당하는 라우터입니다.
///
/// - 역할:
///     - 로그인 및 회원가입 관련 화면 이동을 처리
///     - 로그인 성공 시, `MainTabController`를 루트로 설정
///
/// - 주요 사용처:
///     - 앱 초기 진입 흐름 (로그인 상태에 따라 분기)
///     - 회원가입 화면 이동
///
/// - 설계 이유:
///     - 로그인 흐름을 별도 모듈로 분리하여 각 기능 간 의존성 최소화
///     - Router Pattern 기반으로 UIKit 내 화면 전환 책임을 명확히 분리
final class AuthRouter: AuthRouterProtocol {

    // MARK: - Dependencies

    private var mainTabRouter: MainTabBarRouterProtocol?
    private var feedRouter: FeedRouterProtocol?
    private var notificationRouter: NotificationRouterProtocol?

    private let userRepository: UserRepositoryProtocol
    private let explorerRouter: ExplorerRouterProtocol
    private let signUpUseCase: SignUpUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let notificationUseCase: NotificationUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol

    // MARK: - Initializer

    init(userRepository: UserRepositoryProtocol, explorerRouter: ExplorerRouterProtocol, signUpUseCase: SignUpUseCaseProtocol, logoutUseCase: LogoutUseCaseProtocol, tweetReposiotry: TweetRepositoryProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, notificationUseCase: NotificationUseCaseProtocol, followUseCase: FollowUseCaseProtocol) {
        self.userRepository = userRepository
        self.explorerRouter = explorerRouter
        self.signUpUseCase = signUpUseCase
        self.logoutUseCase = logoutUseCase
        self.tweetRepository = tweetReposiotry
        self.tweetLikeUseCase = tweetLikeUseCase
        self.notificationUseCase = notificationUseCase
        self.followUseCase = followUseCase
    }

    // MARK: - Dependency Injection

    /// 로그인 성공 후 진입할 메인 탭 라우터를 외부에서 주입
    func injectMainTabRouter(mainTabRouter: MainTabBarRouterProtocol) {
        self.mainTabRouter = mainTabRouter
    }

    /// 피드 라우터 주입 (탭 내부 전환 시 필요)
    func injectFeedRouter(feedRouter: FeedRouterProtocol) {
        self.feedRouter = feedRouter
    }

    /// 알림 라우터 주입 (탭 내부 전환 시 필요)
    func injectNotificationRouter(notificationRouter: NotificationRouterProtocol) {
        self.notificationRouter = notificationRouter
    }

    // MARK: - Navigation

    /// 목적지에 따라 화면 이동 처리
    /// - Parameters:
    ///   - destination: 이동할 목적지 (로그인 or 회원가입)
    ///   - from: 현재 뷰 컨트롤러
    func navigate(to destination: AuthDestination, from viewController: UIViewController) {
        switch destination {
        case .login:
            // 로그인 성공 → MainTabController로 전환
            guard let mainTabRouter, let feedRouter, let notificationRouter else { return }

            let mainTabController = MainTabController(
                router: mainTabRouter,
                feedRouter: feedRouter,
                explorerRouter: explorerRouter,
                userRepository: userRepository,
                logoutUseCase: logoutUseCase,
                tweetRepository: tweetRepository,
                tweetLikeUseCase: tweetLikeUseCase,
                notificationUseCase: notificationUseCase,
                notificationRouter: notificationRouter,
                followUseCase: followUseCase
            )
            mainTabController.modalPresentationStyle = .fullScreen
            viewController.present(mainTabController, animated: true)

        case .register:
            // 회원가입 화면으로 Push
            let registerVC = RegisterViewController(router: self, signUpUseCase: signUpUseCase)
            viewController.navigationController?.pushViewController(registerVC, animated: true)
        }
    }

    /// 현재 화면을 네비게이션 스택에서 pop
    /// - Parameter from: 현재 화면 뷰컨
    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
