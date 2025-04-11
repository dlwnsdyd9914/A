//
//  MainTabRouter.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class MainTabRouter: MainTabBarRouterProtocol {



    private let diContainer: AppDIContainer

    private var authRouter: AuthRouterProtocol?
    private var uploadTweetRouter: UploadTweetRouterProtocol?


    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
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
            loginUseCase: diContainer.makeLoginUseCase()
        )
        let nav = UINavigationController(rootViewController: loginVC)

        if let window = viewController.view.window {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func logout(from viewController: UIViewController) {
        guard let authRouter else { return }

        let loginViewController = UINavigationController(rootViewController: LoginViewController(router: authRouter, loginUseCase: diContainer.makeLoginUseCase()))
        loginViewController.modalPresentationStyle = .fullScreen
        viewController.present(loginViewController, animated: true)
    }

    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        
        switch destination {
        case .uploadTweet(let userViewModel):
            guard let uploadTweetRouter else { return }
            let uploadTweetController = UINavigationController(rootViewController: UploadTweetController(router: uploadTweetRouter, userViewModel: userViewModel, useCase: diContainer.makeUploadTweetUseCase()))
            uploadTweetController.modalPresentationStyle = .fullScreen
            viewController.present(uploadTweetController, animated: true)
        }

    }

    func popNav(from viewController: UIViewController) {

    }


}
