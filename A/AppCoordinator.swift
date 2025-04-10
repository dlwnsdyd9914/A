
//
//  AppCoordinator.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let navigationController: UINavigationController

    private let diContainer: AppDIContainer
    private var authCoordinator: AuthCoordinator?
    private var mainTabCoordinator: MainTabCoordinator?

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.diContainer = diContainer
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showMainTabFlow()
    }


    func showMainTabFlow() {

        let userRepository = UserRepository(service: diContainer.makeUserService())

        let authCoordinator = AuthCoordinator(navigationController: UINavigationController(), signUpUserCase: diContainer.makeSignUpUseCase(), loginUseCase: diContainer.makeLoginUseCase(), userRepoistry: userRepository)

        let mainTabCoordinator = MainTabCoordinator(window: window, authCoordinator: authCoordinator, userRepository: userRepository)

        self.mainTabCoordinator = mainTabCoordinator

        authCoordinator.setMainTabRouting(mainTabCoordinator)

        mainTabCoordinator.start()
    }

}

