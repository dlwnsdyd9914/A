////
////  MainTabCoordinator.swift
////  A
////
////  Created by 이준용 on 4/10/25.
////
//
//import UIKit
//
//protocol MainTabFlowDelegate: AnyObject {
//    func didRequestLogout()
//}
//
//final class MainTabCoordinator: MainTabRouting {
//
//    weak var flowDelegate: MainTabFlowDelegate?
//
//    private weak var window: UIWindow?
////    private let authCoordinator: AuthCoordinator
//
//    private let userRepository: UserRepository
//    private let logoutUseCase: LogoutUseCase
//
//    init(window: UIWindow?, authCoordinator: AuthCoordinator, userRepository: UserRepository, logoutUseCase: LogoutUseCase) {
//        self.window = window
//        self.authCoordinator = authCoordinator
//        self.userRepository = userRepository
//        self.logoutUseCase = logoutUseCase
//    }
//
//    func start() {
//        let mainTab = MainTabController(router: self, userRepository: userRepository, logoutUseCase: logoutUseCase)
//
//        UIView.transition(with: window!, duration: 0.25, options: .transitionCrossDissolve, animations: {
//            self.window?.rootViewController = mainTab
//        }, completion: nil)
//    }
//
//
//    func showLogin() {
//        let loginVC = UINavigationController(rootViewController: LoginViewController(router: authCoordinator, loginUseCase: authCoordinator.loginUseCase))
//        loginVC.modalPresentationStyle = .fullScreen
//
//        if let root = window?.rootViewController {
//            if let presented = root.presentedViewController {
//                // 👉 먼저 dismiss 하고
//                presented.dismiss(animated: true) {
//                    // 👉 dismiss 완료되면 로그인 화면 present
//                    root.present(loginVC, animated: false)
//                }
//            } else {
//                root.present(loginVC, animated: true)
//            }
//        }
//    }
//
//    func logout() {
//
//        // 로그인 화면 모달로 띄움
//        let loginVC = UINavigationController(
//            rootViewController: LoginViewController(
//                router: authCoordinator,
//                loginUseCase: authCoordinator.loginUseCase
//            )
//        )
//        loginVC.modalPresentationStyle = .fullScreen
//        window?.rootViewController?.present(loginVC, animated: true)
//
//        // 딜레이 줘서 루트 교체 애니메이션 충돌 방지
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.flowDelegate?.didRequestLogout()
//        }
//    }
//
//    func navigate(to destination: TweetDestination) {
//        switch destination {
//        case .uploadTweet:
//            let uploadTweetController = UINavigationController(rootViewController: UploadTweetController())
//            uploadTweetController.modalPresentationStyle = .fullScreen
//            window?.rootViewController?.present(uploadTweetController, animated: true)
//        }
//    }
//
//    func popView() {
//        window?.rootViewController?.dismiss(animated: true)
//    }
//
//
//
//}
//
//extension MainTabCoordinator: Coordinator {}
//
