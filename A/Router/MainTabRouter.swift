//
//  MainTabRouter.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class MainTabRouter: MainTabBarRouterProtocol {

    

    private let diContainer: AppDIContainer

    private var router: AuthRouterProtocol?


    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
    }

    func setAuthRouter(authRouter: AuthRouterProtocol){
        self.router = authRouter
    }

    func showLogin(from viewController: UIViewController) {
    }

    func logout(from viewController: UIViewController) {
        guard let router else { return }

        let loginViewController = UINavigationController(rootViewController: LoginViewController(router: router, loginUseCase: diContainer.makeLoginUseCase()))
        loginViewController.modalPresentationStyle = .fullScreen
        viewController.present(loginViewController, animated: true)
    }

    func navigate(to destination: TweetDestination, from viewController: UIViewController) {

    }
    
    func popNav(from viewController: UIViewController) {

    }
    

}
