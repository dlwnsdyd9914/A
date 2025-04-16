//
//  NotificationController.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import SwiftUI

/// 사용자 알림 목록을 보여주는 컨트롤러
/// - MVVM 아키텍처 기반으로 NotificationViewModel과 바인딩
/// - Follow 및 Tweet 관련 알림 탭 시, 유저 프로필 또는 트윗 디테일로 라우팅 처리
/// - UITableView + NotificationCell을 사용해 리스트 UI 구성
final class NotificationController: UIViewController {

    // MARK: - Dependencies (DI 기반 주입)

    /// 알림 화면 내 네비게이션 처리를 담당하는 라우터
    private let router: NotificationRouterProtocol

    /// 트윗 좋아요, 트윗 디테일 등과 연결되는 리포지토리 및 유즈케이스
    private let tweetRepository: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let useCase: NotificationUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let userRepository: UserRepositoryProtocol

    /// 테이블뷰 새로고침 컨트롤
    private let refreshControl = UIRefreshControl()

    // MARK: - View Models

    /// 알림 데이터 및 상태를 관리하는 뷰모델
    private let viewModel: NotificationViewModel

    // MARK: - UI Components

    /// 알림 목록을 보여주는 테이블 뷰
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Initializer

    /// 외부 주입된 객체들을 통해 초기화
    init(router: NotificationRouterProtocol, useCase: NotificationUseCaseProtocol, tweetRepository: TweetRepositoryProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, followUseCase: FollowUseCaseProtocol, userRepository: UserRepositoryProtocol) {
        self.router = router
        self.useCase = useCase
        self.viewModel = NotificationViewModel(useCase: useCase)
        self.tweetLikeUseCase = tweetLikeUseCase
        self.tweetRepository = tweetRepository
        self.followUseCase = followUseCase
        self.userRepository = userRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 알림화면 진입 시 네비게이션바 보이도록 설정
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        bindViewModel()
    }

    // MARK: - Selectors

    /// 당겨서 새로고침 동작 시 알림 재요청
    @objc private func handleRefresh() {
        viewModel.fetchNotifications()
    }

    // MARK: - UI Configurations

    /// 네비게이션바 스타일 및 타이틀 설정
    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        self.navigationItem.title = "알림"
    }

    /// 배경 색상 설정
    private func configureUI() {
        self.view.backgroundColor = .white
    }

    /// 테이블뷰 레이아웃 및 셀 등록, 바인딩 설정
    private func configureTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tableView.rowHeight = 60
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(NotificationCell.self, forCellReuseIdentifier: CellIdentifier.notificationCell)

        // 새로고침 설정
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    // MARK: - Bind ViewModels

    /// ViewModel과 UI 간 바인딩 처리
    private func bindViewModel() {
        viewModel.onFeatchNotification = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }

        viewModel.fetchNotifications()
    }
}

// MARK: - UITableViewDataSource

extension NotificationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.notificationCell, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }

        let item = viewModel.notifications[indexPath.row]

        // 셀에 들어갈 뷰모델 생성 및 바인딩
        let notificationCellViewModel = NotificationCellViewModel(item: item, useCase: followUseCase)
        cell.viewModel = notificationCellViewModel

        // 팔로우 상태 변경 시 리스트 갱신
        cell.viewModel?.onFollowToggled = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = viewModel.notifications[indexPath.row]

        // 유저 관련 화면 이동을 위한 뷰모델 준비
        let userViewModel = UserViewModel(user: notification.user, followUseCase: followUseCase)
        guard let type = notification.notification.type else { return }

        switch type {
        case .follow:
            // 팔로우 알림 -> 유저 프로필 이동
            router.navigate(to: .userProfile(userViewModel: userViewModel), from: self)

        case .like, .mention, .reply, .retweet:
            // 트윗 관련 알림 -> 트윗 디테일 이동
            guard let tweet = notification.tweet else { return }

            let tweetViewModel = TweetViewModel(
                tweet: tweet,
                repository: tweetRepository,
                useCase: tweetLikeUseCase,
                userViewModel: userViewModel,
                userRepository: userRepository
            )
            
            router.navigate(to: .tweetDetail(tweetViewModel: tweetViewModel, userViewModel: userViewModel), from: self)
        }
    }
}

// MARK: - Xcode Preview (디버깅/프리뷰 용)

#Preview {
    let mockUseCase = MockNotificationUseCase()
    let mockRouter = MockNotificationRouter()
    let mockTweetRepository = MockTweetRepository()
    let mockTweetLikeUseCase = MockTweetLikeUseCase()
    let mockFollowUseCase = MockFollowUseCase()
    let mockUserRepository = MockUserRepository()

    VCPreView {
        UINavigationController(
            rootViewController: NotificationController(
                router: mockRouter,
                useCase: mockUseCase,
                tweetRepository: mockTweetRepository,
                tweetLikeUseCase: mockTweetLikeUseCase,
                followUseCase: mockFollowUseCase,
                userRepository: mockUserRepository
            )
        )
    }.edgesIgnoringSafeArea(.all)
}
