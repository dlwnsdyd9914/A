// AuthCoordinator.swift
import UIKit

final class AuthCoordinator: AuthRouting {

    private let signUpUseCase: SignUpUseCase
    let loginUseCase: LoginUseCase
    private let userRepositry: UserRepository

    private var mainTabRouter: MainTabRouting?  // ✅ 옵셔널로 변경
    private weak var nav: UINavigationController?

    init(navigationController: UINavigationController, signUpUserCase: SignUpUseCase, loginUseCase: LoginUseCase, userRepoistry: UserRepository) {
        self.nav = navigationController
        self.signUpUseCase = signUpUserCase
        self.loginUseCase = loginUseCase
        self.userRepositry = userRepoistry
    }

    // ✅ mainTabRouter setter
    func setMainTabRouting(_ routing: MainTabRouting) {
        self.mainTabRouter = routing
    }

    func start() {
        navigate(to: .login)
    }

    func navigate(to destination: AuthDestination) {
        switch destination {
        case .login:
            let loginVC = LoginViewController(router: self, loginUseCase: loginUseCase)
            nav?.setViewControllers([loginVC], animated: false)

        case .register:
            let vc = RegisterViewController(router: self, signUpUseCase: signUpUseCase)
            nav?.pushViewController(vc, animated: true)

        case .main:
            guard let mainTabRouter else { return }
            let vc = MainTabController(router: mainTabRouter, userRepository: userRepositry)
            vc.modalPresentationStyle = .fullScreen
            nav?.topViewController?.present(vc, animated: true)
        }
    }

    func popNav() {
        nav?.popViewController(animated: true)
    }

   
}

