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

final class MainTabController: UITabBarController {

    // MARK: - Properties


    private let viewModel: MainTabViewModel
    private var userViewModel: UserViewModel?
    private let logoutUseCase: LogoutUseCaseProtocol
    private let router: MainTabBarRouterProtocol

    // MARK: - View Models

    // MARK: - UI Components

    private lazy var newTweetButton = UIButton(type: .custom).then {
        $0.setImage(.newTweetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.backgroundColor = .backGround
        $0.tintColor = .imagePrimary
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleNewTweetButton), for: .touchUpInside)
    }

    // MARK: - Initializer

    init(userRepository: UserRepositoryProtocol, logoutUseCase: LogoutUseCaseProtocol, router: MainTabBarRouterProtocol) {

        self.viewModel = MainTabViewModel(userRepository: userRepository)
        self.logoutUseCase = logoutUseCase
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Life Cycles
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
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            
        }
    }

    // MARK: - UI Configurations

    private func configureTabbar() {
        let appearance = UITabBarAppearance()
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance

        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
    }

    private func constructTabController(image: UIImage, viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }

    private func makeTabbarController() {

        guard let userViewModel = userViewModel else { return }

        let tabs: [(UIImage, UIViewController)] = [
            (UIImage.feedImage, FeedController(userViewModel: userViewModel, logoutUseCase: logoutUseCase, router: router)),
            (UIImage.searchImage, ExplorerController()),
            (UIImage.like, NotificationController())
        ]

        viewControllers = tabs.map({self.constructTabController(image: $0, viewController: $1)})
    }

    private func addSubViews() {
        view.addSubview(newTweetButton)
    }

    private func setNewTweetButtonConstraints() {
        newTweetButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(64)
            $0.size.equalTo(64)
        })
    }



    // MARK: - Functions

    private func checkingLogin() {
        if Auth.auth().currentUser != nil {
            print("✅로그인 상태!")
        } else {
            print("❗️로그아웃 상태!")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                router.showLogin(from: self)
            }
        }
    }

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onFetchUser = {[weak self] user in
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
