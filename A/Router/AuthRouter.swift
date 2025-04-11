//
//  AuthRouter.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class AuthRouter: AuthRouterProtocol {

    private let diContainer: AppDIContainer

    private var mainTabRouter: MainTabBarRouterProtocol?

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
    }

    func setMainTabRouter(mainTabRouter: MainTabBarRouterProtocol) {
        self.mainTabRouter = mainTabRouter
    }

    func navigate(to destination: AuthDestination, from viewController: UIViewController) {
        switch destination {
        case .login:
            guard let mainTabRouter = mainTabRouter else { return }
            let mainTabController = MainTabController(userRepository: diContainer.makeUserRepository(), logoutUseCase: diContainer.makeLogoutUseCase(), router: mainTabRouter)
            mainTabController.modalPresentationStyle = .fullScreen
            viewController.present(mainTabController, animated: true)
        case .register:

            let registerViewController = RegisterViewController(router: self, signUpUseCase: diContainer.makeSignUpUseCase())
            viewController.navigationController?.pushViewController(registerViewController, animated: true)
        }
    }
    
    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    

}
