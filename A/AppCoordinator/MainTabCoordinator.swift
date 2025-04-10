//
//  MainTabCoordinator.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class MainTabCoordinator: MainTabRouting {

    private weak var window: UIWindow?
    private let authCoordinator: AuthCoordinator

    private let userRepository: UserRepository

    init(window: UIWindow?, authCoordinator: AuthCoordinator, userRepository: UserRepository) {
        self.window = window
        self.authCoordinator = authCoordinator
        self.userRepository = userRepository
    }

    func start() {
        let mainTab = MainTabController(router: self, userRepository: userRepository)
        window?.rootViewController = mainTab
        window?.makeKeyAndVisible()
    }

    func showLogin() {
        let loginVC = UINavigationController(rootViewController: LoginViewController(router: authCoordinator, loginUseCase: authCoordinator.loginUseCase))
        loginVC.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(loginVC, animated: true)
    }
}
