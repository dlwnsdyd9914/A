//
//  MainTabBarRouter.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class MainTabBarRouter: MainTabBarRouterProtocol {
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        
    }
    
    func popNav(from viewController: UIViewController) {

    }
    

    private weak var window: UIWindow?
    private let diContainer: AppDIContainer
    private var authRouter: AuthRouterProtocol? // ✅ 오타 수정

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.diContainer = diContainer
    }

    func setAuthRouter(_ router: AuthRouterProtocol) { // ✅ 오타 수정
        self.authRouter = router
    }

    func showLogin() {
        logout() // 👈 필요하면 이거로 대체 가능
    }

    func logout() {
        guard let authRouter else {
            assertionFailure("❌ authRouter가 주입되지 않았습니다.")
            return
        }

        let loginVC = LoginViewController(
            router: authRouter,
            loginUseCase: diContainer.makeLoginUseCase()
        )

        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController?.present(nav, animated: true)
    }

    func navigate(to destination: TweetDestination) {
        // 이후 트윗 관련 화면 전환 로직 작성
    }

    func popView() {
        // 추후 필요 시 navigation pop 로직 구현
    }
}

