//
//  MainTabController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import SnapKit
import Then
import Firebase

/// 앱의 메인 탭 컨트롤러입니다.
/// 로그인 이후 진입되는 루트 화면으로, Feed / Explore / Notification 탭을 관리합니다.
/// MVVM 구조 기반으로 유저 정보를 받아와 탭 구성 및 화면 이동 처리를 담당합니다.
final class MainTabController: UITabBarController {

    // MARK: - Properties

    /// 유저 정보 요청을 위한 뷰모델
    private let viewModel: MainTabViewModel

    /// 현재 로그인된 사용자 정보 뷰모델
    private var userViewModel: UserViewModel?

    /// 화면 전환을 담당하는 라우터
    private let router: MainTabBarRouterProtocol

    /// DI를 위한 컨테이너
    private let diContainer: AppDIContainer

    // MARK: - UI Components

    /// 새로운 트윗 작성 버튼
    private lazy var newTweetButton = UIButton(type: .custom).then {
        $0.setImage(.newTweetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.backgroundColor = .backGround
        $0.tintColor = .imagePrimary
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleNewTweetButton), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// DI 컨테이너와 라우터를 주입 받아 초기화합니다.
    init(diContainer: AppDIContainer, router: MainTabBarRouterProtocol) {
        self.diContainer = diContainer
        self.viewModel = MainTabViewModel(userRepository: diContainer.makeUserRepository())
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
        checkingLogin()
        addSubViews()
        setNewTweetButtonConstraints()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newTweetButton.layer.cornerRadius = newTweetButton.frame.height / 2
    }

    // MARK: - Selectors

    /// 트윗 작성 버튼을 눌렀을 때 호출되는 함수
    @objc private func handleNewTweetButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let userViewModel else { return }
            router.navigate(to: .uploadTweet(userViewModel: userViewModel), from: self)
        }
    }

    // MARK: - UI Configurations

    /// 탭바 기본 설정
    private func configureTabbar() {
        let appearance = UITabBarAppearance()
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance

        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
    }

    /// 각 탭을 UINavigationController로 래핑하여 구성
    private func constructTabController(image: UIImage, viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }

    /// 탭바 컨트롤러 구성
    private func makeTabbarController() {
        guard let userViewModel = userViewModel else { return }

        let tabs: [(UIImage, UIViewController)] = [
            (
                UIImage.feedImage,
                FeedController(
                    userViewModel: userViewModel,
                    logoutUseCase: diContainer.makeLogoutUseCase(),
                    router: router,
                    repository: diContainer.makeTweetRepository()
                )
            ),
            (UIImage.searchImage, ExplorerController()),
            (UIImage.like, NotificationController())
        ]

        viewControllers = tabs.map {
            self.constructTabController(image: $0, viewController: $1)
        }
    }

    /// 서브뷰 추가
    private func addSubViews() {
        view.addSubview(newTweetButton)
    }

    /// 트윗 작성 버튼 오토레이아웃
    private func setNewTweetButtonConstraints() {
        newTweetButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(64)
            $0.size.equalTo(64)
        }
    }

    // MARK: - Functions

    /// 로그인 여부를 확인하고, 로그아웃 상태면 로그인 화면으로 전환
    private func checkingLogin() {
        if Auth.auth().currentUser != nil {
            print("✅로그인 상태!")
        } else {
            print("❗️로그아웃 상태! 로그인 화면으로 이동")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                router.showLogin(from: self)
            }
        }
    }

    // MARK: - ViewModel Bindings

    /// 사용자 정보가 fetch 되었을 때 탭 구성 트리거
    private func bindViewModel() {
        viewModel.onFetchUser = { [weak self] user in
            guard let self else { return }

            DispatchQueue.main.async {
                self.userViewModel = UserViewModel(user: user)

                if self.viewControllers?.isEmpty ?? true {
                    self.makeTabbarController()
                }
            }
        }

        viewModel.fetchUser()
    }
}
