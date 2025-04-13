//
//  AuthRouter.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

/// 로그인/회원가입 화면의 네비게이션을 담당하는 라우터
final class AuthRouter: AuthRouterProtocol {

    // MARK: - Properties


    /// 메인 탭 라우터 - 로그인 성공 시 메인 화면 전환을 위해 필요
    private var mainTabRouter: MainTabBarRouterProtocol?

    private var feedRouter: FeedRouterProtocol?

    private let userRepository: UserRepositoryProtocol

    private let explorerRouter: ExplorerRouterProtocol

    private let signUpUseCase: SignUpUseCaseProtocol

    private let logoutUseCase: LogoutUseCaseProtocol

    private let tweetRepository: TweetRepositoryProtocol

    private let tweetLikeUseCase: TweetLikeUseCaseProtocol

    private let notificationUseCase: NotificationUseCaseProtocol

    // MARK: - Initializer

    init(userRepository: UserRepositoryProtocol, explorerRouter: ExplorerRouterProtocol, signUpUseCase: SignUpUseCaseProtocol, logoutUseCase: LogoutUseCaseProtocol, tweetReposiotry: TweetRepositoryProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, notificationUseCase: NotificationUseCaseProtocol) {
        self.userRepository = userRepository
        self.explorerRouter = explorerRouter
        self.signUpUseCase = signUpUseCase
        self.logoutUseCase = logoutUseCase
        self.tweetRepository = tweetReposiotry
        self.tweetLikeUseCase = tweetLikeUseCase
        self.notificationUseCase = notificationUseCase
    }

    // MARK: - Dependency Injection

    /// 외부에서 MainTabRouter를 주입 (App 진입 지점에서 설정)
    func injectMainTabRouter(mainTabRouter: MainTabBarRouterProtocol) {
        self.mainTabRouter = mainTabRouter
    }

    func injectFeedRouter(feedRouter: FeedRouterProtocol) {
        self.feedRouter = feedRouter
    }


    // MARK: - Navigation

    /// 목적지(destination)에 따라 화면 이동 처리
    func navigate(to destination: AuthDestination, from viewController: UIViewController) {
        switch destination {
        case .login:
            // 로그인 성공 후 메인탭으로 이동
            guard let mainTabRouter,
                  let feedRouter else { return }
            let mainTabController = MainTabController(router: mainTabRouter, feedRouter: feedRouter, explorerRouter: explorerRouter, userRepository: userRepository, logoutUseCase: logoutUseCase, tweetRepository: tweetRepository, tweetLikeUseCase: tweetLikeUseCase, notificationUseCase: notificationUseCase)
            mainTabController.modalPresentationStyle = .fullScreen
            viewController.present(mainTabController, animated: true)

        case .register:
            // 회원가입 화면으로 Push
            let registerVC = RegisterViewController(router: self, signUpUseCase: signUpUseCase)
            viewController.navigationController?.pushViewController(registerVC, animated: true)
        }
    }

    /// 현재 ViewController를 pop
    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}



