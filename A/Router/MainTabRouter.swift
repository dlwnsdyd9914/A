//
//  MainTabRouter.swift
//  A
//
//

import UIKit

/// 앱의 메인 탭 흐름에서 라우팅을 담당하는 라우터입니다.
///
/// - 역할:
///     - 로그인/로그아웃 상태에 따라 초기 루트 뷰 전환
///     - 트윗 업로드 목적에 따른 업로드 화면 호출
///     - 탭 내에서의 기본적인 pop 처리 제공
///
/// - 주요 사용처:
///     - AppCoordinator or SceneDelegate 에서 앱의 진입 흐름 제어 시
///     - 로그인/로그아웃 전환 처리 시
///     - Tweet 업로드 흐름 연결 시
///
/// - 설계 이유:
///     - 탭 루트 레벨에서 필요한 화면 전환 및 연결 지점을 한 곳에서 관리
///     - AuthRouter 및 UploadTweetRouter와의 협력 구성으로 기능 분리
final class MainTabRouter: MainTabBarRouterProtocol {

    // MARK: - Dependencies

    private var authRouter: AuthRouterProtocol?
    private var uploadTweetRouter: UploadTweetRouterProtocol?

    private let loginUseCase: LoginUseCaseProtocol

    // MARK: - Initializer

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    // MARK: - Injection

    /// 로그인 라우터를 외부에서 주입합니다.
    func setAuthRouter(authRouter: AuthRouterProtocol) {
        self.authRouter = authRouter
    }

    /// 트윗 업로드 라우터를 외부에서 주입합니다.
    func setUploadTWeetRouter(uploadTweetRouter: UploadTweetRouterProtocol) {
        self.uploadTweetRouter = uploadTweetRouter
    }

    // MARK: - Navigation

    /// 로그인 화면을 루트 뷰로 설정합니다. (앱 진입 시 최초 진입점)
    func showLogin(from viewController: UIViewController) {
        guard let authRouter else { return }

        let loginVC = LoginViewController(router: authRouter, loginUseCase: loginUseCase)
        let nav = UINavigationController(rootViewController: loginVC)

        if let window = viewController.view.window {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    /// 로그아웃 후 로그인 화면으로 전환합니다.
    func logout(from viewController: UIViewController) {
        guard let authRouter else { return }

        let loginViewController = UINavigationController(rootViewController: LoginViewController(router: authRouter, loginUseCase: loginUseCase))
        loginViewController.modalPresentationStyle = .fullScreen
        viewController.present(loginViewController, animated: true)
    }

    /// 트윗 업로드 목적에 따라 업로드 화면으로 이동합니다.
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        uploadTweetRouter?.navigate(to: destination, from: viewController)
    }

    // MARK: - Navigation Helpers

    /// 내비게이션 컨트롤러에서 현재 화면을 pop합니다.
    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
