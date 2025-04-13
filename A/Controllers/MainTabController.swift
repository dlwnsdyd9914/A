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

    private let viewModel: MainTabViewModel
    private var userViewModel: UserViewModel?

    private let router: MainTabBarRouterProtocol
    private let feedRouter: FeedRouterProtocol
    private let explorerRouter: ExplorerRouterProtocol

    private let logoutUseCase: LogoutUseCaseProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let notificationUseCase: NotificationUseCaseProtocol

    // MARK: - UI Components

    private lazy var newTweetButton = UIButton(type: .custom).then {
        $0.setImage(.newTweetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.backgroundColor = .backGround
        $0.tintColor = .imagePrimary
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleNewTweetButton), for: .touchUpInside)
    }

    // MARK: - Initializer

    init(
        router: MainTabBarRouterProtocol,
        feedRouter: FeedRouterProtocol,
        explorerRouter: ExplorerRouterProtocol,
        userRepository: UserRepositoryProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        tweetRepository: TweetRepositoryProtocol,
        tweetLikeUseCase: TweetLikeUseCaseProtocol,
        notificationUseCase: NotificationUseCaseProtocol
    ) {
        self.viewModel = MainTabViewModel(userRepository: userRepository)
        self.router = router
        self.feedRouter = feedRouter
        self.explorerRouter = explorerRouter
        self.logoutUseCase = logoutUseCase
        self.tweetRepository = tweetRepository
        self.userRepository = userRepository
        self.tweetLikeUseCase = tweetLikeUseCase
        self.notificationUseCase = notificationUseCase
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

    @objc private func handleNewTweetButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let userViewModel else { return }
            router.navigate(to: .uploadTweet(userViewModel: userViewModel), from: self)
        }
    }

    // MARK: - UI Configurations

    private func configureTabbar() {
        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
    }

    private func constructTabController(image: UIImage, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.tabBarItem.image = image
        return nav
    }

    private func makeTabbarController() {
        guard let userViewModel else { return }

        let tabs: [(UIImage, UIViewController)] = [
            (
                .feedImage,
                FeedController(
                    userViewModel: userViewModel,
                    logoutUseCase: logoutUseCase,
                    router: router,
                    repository: tweetRepository,
                    feedRouter: feedRouter, tweetLikeUseCase: tweetLikeUseCase
                )
            ),
            (
                .searchImage,
                ExplorerController(
                    repository: userRepository,
                    userViewModel: userViewModel,
                    router: explorerRouter
                )
            ),
            (
                .like,
                NotificationController(useCase: notificationUseCase)
            )
        ]

        viewControllers = tabs.map {
            constructTabController(image: $0, viewController: $1)
        }
    }

    private func addSubViews() {
        view.addSubview(newTweetButton)
    }

    private func setNewTweetButtonConstraints() {
        newTweetButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(64)
            $0.size.equalTo(64)
        }
    }

    // MARK: - Functions

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
