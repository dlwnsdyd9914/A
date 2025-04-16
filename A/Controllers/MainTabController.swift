//
//  MainTabController.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import Firebase

/// 메인 탭 화면 컨트롤러
/// - 로그인 후 진입되는 루트 컨테이너로, Feed / Explorer / Notification 탭을 관리
/// - MVVM 아키텍처 기반으로 유저 정보를 패칭하여 탭 화면 구성
/// - 새로운 트윗 작성 버튼 포함, 각 탭은 Router를 통해 화면 전환 처리
final class MainTabController: UITabBarController {

    // MARK: - Dependencies

    /// 유저 정보 조회 및 탭 구성 로직을 담당하는 뷰모델
    private let viewModel: MainTabViewModel

    /// 현재 로그인된 유저를 표현하는 뷰모델 (탭 화면에 전달됨)
    private var userViewModel: UserViewModel?

    /// 탭 및 트윗 업로드 등의 화면 전환을 처리하는 라우터
    private let router: MainTabBarRouterProtocol

    /// 탭 별 라우터 (탭 내 세부 화면 전환 전담)
    private let feedRouter: FeedRouterProtocol
    private let explorerRouter: ExplorerRouterProtocol
    private let notificationRouter: NotificationRouterProtocol

    /// 의존성 주입을 위한 유스케이스 및 저장소
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let notificationUseCase: NotificationUseCaseProtocol

    // MARK: - UI Components

    /// 트윗 업로드 버튼 (화면 우하단 고정형)
    private lazy var newTweetButton = UIButton(type: .custom).then {
        $0.setImage(.newTweetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.backgroundColor = .backGround
        $0.tintColor = .imagePrimary
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleNewTweetButton), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// DI 기반 생성자 - 모든 의존성을 외부에서 주입받아 구성
    init(
        router: MainTabBarRouterProtocol,
        feedRouter: FeedRouterProtocol,
        explorerRouter: ExplorerRouterProtocol,
        userRepository: UserRepositoryProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        tweetRepository: TweetRepositoryProtocol,
        tweetLikeUseCase: TweetLikeUseCaseProtocol,
        notificationUseCase: NotificationUseCaseProtocol,
        notificationRouter: NotificationRouterProtocol,
        followUseCase: FollowUseCaseProtocol
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
        self.notificationRouter = notificationRouter
        self.followUseCase = followUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
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

    /// 트윗 업로드 버튼 탭 시 업로드 화면으로 라우팅
    @objc private func handleNewTweetButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let userViewModel else { return }
            router.navigate(to: .uploadTweet(userViewModel: userViewModel), from: self)
        }
    }

    // MARK: - UI Configurations

    /// 탭바 기본 스타일 설정 (컬러 등 appearance 설정)
    private func configureTabbar() {
        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
    }

    /// 각 탭 화면을 UINavigationController로 감싸고 아이콘 지정
    private func constructTabController(image: UIImage, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.tabBarItem.image = image
        return nav
    }

    /// 유저 정보 바인딩 이후 실제 탭 컨트롤러 구성
    /// - 유저 기반으로 Feed / Explorer / Notification 화면 각각 구성
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
                    feedRouter: feedRouter,
                    tweetLikeUseCase: tweetLikeUseCase,
                    followUseCase: followUseCase,
                    userRepository: userRepository
                )
            ),
            (
                .searchImage,
                ExplorerController(
                    repository: userRepository,
                    userViewModel: userViewModel,
                    router: explorerRouter,
                    followUseCase: followUseCase
                )
            ),
            (
                .like,
                NotificationController(
                    router: notificationRouter,
                    useCase: notificationUseCase,
                    tweetRepository: tweetRepository,
                    tweetLikeUseCase: tweetLikeUseCase,
                    followUseCase: followUseCase,
                    userRepository: userRepository
                )
            )
        ]

        viewControllers = tabs.map {
            constructTabController(image: $0, viewController: $1)
        }
    }

    /// 플로팅 트윗 버튼 추가
    private func addSubViews() {
        view.addSubview(newTweetButton)
    }

    /// 트윗 버튼 레이아웃 구성
    private func setNewTweetButtonConstraints() {
        newTweetButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(64)
            $0.size.equalTo(64)
        }
    }

    // MARK: - Auth 상태 확인

    /// Firebase 인증 상태 체크
    /// - 비로그인 상태일 경우 로그인 화면으로 강제 전환
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

    /// ViewModel에서 유저 정보를 패칭 후 뷰모델 바인딩 및 탭 생성
    private func bindViewModel() {
        viewModel.onFetchUser = { [weak self] user in
            guard let self else { return }

            DispatchQueue.main.async {
                self.userViewModel = UserViewModel(user: user, followUseCase: self.followUseCase)

                // 최초 탭 구성
                if self.viewControllers?.isEmpty ?? true {
                    self.makeTabbarController()
                }
            }
        }

        viewModel.fetchUser()
    }
}
