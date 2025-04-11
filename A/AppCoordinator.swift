////
////  AppCoordinator.swift
////  A
////
////  Created by 이준용 on 4/10/25.
////
//
//import UIKit
//
//final class AppCoordinator: Coordinator {
//
//    private let window: UIWindow
//    private let diContainer: AppDIContainer
//
//    private var childCoordinators: [Coordinator] = []
//
//    init(window: UIWindow, diContainer: AppDIContainer) {
//        self.window = window
//        self.diContainer = diContainer
//    }
//
//    func start() {
//        window.makeKeyAndVisible()
//
//        if diContainer.makeAuthService().isLoggedIn {
//            print("✅ 이미 로그인되어 있음 → MainTabCoordinator 실행")
//            showMainTabFlow()
//        } else {
//            print("🔒 로그인 안 되어 있음 → AuthCoordinator 실행")
//            showAuthFlow()
//        }
//    }
//
//    private func showMainTabFlow() {
//        let userRepository = UserRepository(service: diContainer.makeUserService())
//        let logoutUseCase = diContainer.makeLogoutUseCase()
//
//        let authCoordinator = AuthCoordinator(
//            navigationController: UINavigationController(),
//            signUpUserCase: diContainer.makeSignUpUseCase(),
//            loginUseCase: diContainer.makeLoginUseCase(),
//            userRepoistry: userRepository,
//            logoutUseCase: logoutUseCase
//        )
//
//        let mainTabCoordinator = MainTabCoordinator(
//            window: window,
//            authCoordinator: authCoordinator,
//            userRepository: userRepository,
//            logoutUseCase: logoutUseCase
//        )
//
//        authCoordinator.setMainTabRouting(mainTabCoordinator)
//
//        mainTabCoordinator.flowDelegate = self
//
//
//        addChild(authCoordinator)
//        addChild(mainTabCoordinator)
//
//
//
//        mainTabCoordinator.start()
//    }
//
//    private func showAuthFlow() {
//        let userRepository = diContainer.makeUserRepository()
//        let logoutUseCase = diContainer.makeLogoutUseCase()
//
//        let navController = UINavigationController()
//
//        let authCoordinator = AuthCoordinator(
//            navigationController: navController,
//            signUpUserCase: diContainer.makeSignUpUseCase(),
//            loginUseCase: diContainer.makeLoginUseCase(),
//            userRepoistry: userRepository,
//            logoutUseCase: logoutUseCase
//        )
//
//        let mainTabCoordinator = MainTabCoordinator(
//            window: window,
//            authCoordinator: authCoordinator,
//            userRepository: userRepository,
//            logoutUseCase: logoutUseCase
//        )
//
//        authCoordinator.setMainTabRouting(mainTabCoordinator)
//        authCoordinator.flowDelegate = self
//
//        addChild(authCoordinator)
//        addChild(mainTabCoordinator)
//
//        window.rootViewController = navController
//        authCoordinator.start()
//    }
//
//    private func addChild(_ coordinator: Coordinator) {
//        childCoordinators.append(coordinator)
//    }
//
//    private func removeChild(_ coordinator: Coordinator) {
//        childCoordinators.removeAll { $0 === coordinator }
//    }
//}
//
//
//extension AppCoordinator: AuthFlowDelegate {
//    func didLogin() {
//        print("✅ 로그인 성공 → MainTabCoordinator 실행")
//        childCoordinators.removeAll()
//        showMainTabFlow()
//    }
//
//
//}
//
//extension AppCoordinator: MainTabFlowDelegate {
//    func didRequestLogout() {
//        print("🔁 AppCoordinator.didRequestLogout() 호출됨")
//        childCoordinators.removeAll()
//        showAuthFlow()
//    }
//}
//
