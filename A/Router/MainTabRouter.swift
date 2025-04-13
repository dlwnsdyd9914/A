//
//  MainTabRouter.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class MainTabRouter: MainTabBarRouterProtocol {




    private var authRouter: AuthRouterProtocol?
    private var uploadTweetRouter: UploadTweetRouterProtocol?

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }



    func setAuthRouter(authRouter: AuthRouterProtocol){
        self.authRouter = authRouter
    }

    func setUploadTWeetRouter(uploadTweetRouter: UploadTweetRouterProtocol) {
        self.uploadTweetRouter = uploadTweetRouter
    }

    func showLogin(from viewController: UIViewController) {
        guard let authRouter else { return }

        let loginVC = LoginViewController(
            router: authRouter,
            loginUseCase: loginUseCase
        )
        let nav = UINavigationController(rootViewController: loginVC)

        if let window = viewController.view.window {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func logout(from viewController: UIViewController) {
        guard let authRouter else { return }

        let loginViewController = UINavigationController(rootViewController: LoginViewController(router: authRouter, loginUseCase: loginUseCase))
        loginViewController.modalPresentationStyle = .fullScreen
        viewController.present(loginViewController, animated: true)
    }

    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        uploadTweetRouter?.navigate(to: destination, from: viewController)
    }


    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }


}
