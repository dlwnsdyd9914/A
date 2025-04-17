//// AuthCoordinator.swift
//import UIKit
//
//protocol AuthFlowDelegate: AnyObject {
//    func didLogin()
//}
//
//final class AuthCoordinator: AuthRouting {
//
//
//    private let signUpUseCase: SignUpUseCase
//    let loginUseCase: LoginUseCase
//    private let logoutUseCase: LogoutUseCase
//    private let userRepositry: UserRepository
//
//    private var mainTabRouter: MainTabRouting?  // ✅ 옵셔널로 변경
//     weak var navigationController: UINavigationController?
//
//    weak var flowDelegate: AuthFlowDelegate?
//
//    init(navigationController: UINavigationController, signUpUserCase: SignUpUseCase, loginUseCase: LoginUseCase, userRepoistry: UserRepository, logoutUseCase: LogoutUseCase) {
//        self.navigationController = navigationController
//        self.signUpUseCase = signUpUserCase
//        self.loginUseCase = loginUseCase
//        self.userRepositry = userRepoistry
//        self.logoutUseCase = logoutUseCase
//    }
//
//    // ✅ mainTabRouter setter
//    func setMainTabRouting(_ routing: MainTabRouting) {
//        self.mainTabRouter = routing
//    }
//
//    func start() {
//        navigate(to: .login)
//    }
//
//    func navigate(to destination: AuthDestination) {
//        switch destination {
//        case .login:
//            let loginVC = LoginViewController(router: self, loginUseCase: loginUseCase)
//            navigationController?.setViewControllers([loginVC], animated: false)
//
//        case .register:
//            let vc = RegisterViewController(router: self, signUpUseCase: signUpUseCase)
//            navigationController?.pushViewController(vc, animated: true)
//
//        case .main:
//            guard let mainTabRouter else { return }
//
//            let mainTabVC = MainTabController(router: mainTabRouter, userRepository: userRepositry, logoutUseCase: logoutUseCase)
//            mainTabVC.modalPresentationStyle = .fullScreen
//
//            navigationController?.present(mainTabVC, animated: true)
//
//
//            flowDelegate?.didLogin()
//
////            guard let mainTabRouter else {
////                print("❌ mainTabRouter is nil")
////                return
////            }
////
////            let vc = MainTabController(router: mainTabRouter, userRepository: userRepositry, logoutUseCase: logoutUseCase)
////            vc.modalPresentationStyle = .fullScreen
////
////            if let topVC = navigationController?.topViewController {
////                if topVC.presentedViewController != nil {
////                    topVC.dismiss(animated: false) {
////                        topVC.present(vc, animated: true)
////                    }
////                } else {
////                    topVC.present(vc, animated: true)
////                }
////            } else {
////                print("❌ present 실패: topViewController가 nil")
////            }
//        }
//    }
//
//    func popNav() {
//        navigationController?.popViewController(animated: true)
//    }
//}
//
//
//extension AuthCoordinator: Coordinator {}
//
