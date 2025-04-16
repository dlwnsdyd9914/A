//
//  ExplorerController.swift
//  A
//

import UIKit
import SwiftUI
import SnapKit
import Then

/// 사용자 탐색 화면 (Explorer)
/// - 기능: 전체 유저 목록 표시 + UISearchController 기반 사용자 검색 기능 제공
/// - 아키텍처: MVVM + Router 구조
/// - 의존성: FollowUseCase, UserRepository, UserViewModel, Router 주입 방식 사용
/// - 부가 기능: NotificationCenter를 통해 유저 정보 변경을 실시간 반영
final class ExplorerController: UIViewController {

    // MARK: - Properties (UI + DI + 상태)

    /// 사용자 목록을 출력하는 테이블 뷰
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 사용자 검색 기능을 위한 UISearchController
    private let searchController = UISearchController(searchResultsController: nil)

    /// 유저 프로필 화면 전환을 위한 라우터
    private let router: ExplorerRouterProtocol

    /// 팔로우/언팔로우 기능 유즈케이스
    private let folloWUseCase: FollowUseCaseProtocol


    // MARK: - View Models

    /// 검색 결과 및 유저 목록을 관리하는 탐색 전용 뷰모델
    private let viewModel: ExplorerViewModel

    /// 현재 로그인된 사용자 정보
    private let userViewModel: UserViewModel

    // MARK: - Initializer

    /// DI 기반 생성자 - Repository, ViewModel, Router 외부 주입
    init(repository: UserRepositoryProtocol, userViewModel: UserViewModel, router: ExplorerRouterProtocol, followUseCase: FollowUseCaseProtocol) {
        self.viewModel = ExplorerViewModel(repository: repository, userViewModel: userViewModel)
        self.userViewModel = userViewModel
        self.router = router
        self.folloWUseCase = followUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer
    /// Observer 해제 (메모리 누수 방지)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        configureSearchController()
        bindViewModel()
        registerNotificationObservers()
    }

    // MARK: - Selectors

    /// NotificationCenter에서 유저 업데이트 수신 시 반영
    @objc private func handleProfileUpdated(_ notification: Foundation.Notification) {
        guard let updateUser = notification.object as? UserModelProtocol else { return }

        self.viewModel.updatedUser(user: updateUser)
        self.tableView.reloadData()
    }

    // MARK: - UI Configurations

    /// 네비게이션 바 설정
    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.title = "검색"
    }

    /// 배경 색상 설정
    private func configureUI() {
        view.backgroundColor = .white
    }

    /// 테이블 뷰 설정 (SnapKit으로 오토레이아웃 구성)
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(UserCell.self, forCellReuseIdentifier: CellIdentifier.userCell)
    }

    /// UISearchController 설정
    private func configureSearchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "사용자 검색"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }

    /// NotificationCenter 등록
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileUpdated), name: .didUpdateProfile, object: nil)
    }

    // MARK: - Bind ViewModel

    /// ViewModel과 UI간 상태 바인딩
    private func bindViewModel() {
        viewModel.onFetchUserSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.onFilterUserList = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.fetchUserList()
    }
}

// MARK: - UITableViewDataSource

extension ExplorerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inSeaerchMode ? viewModel.filterUserList.count : viewModel.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.userCell, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none

        let user = viewModel.inSeaerchMode ? viewModel.filterUserList[indexPath.row] : viewModel.userList[indexPath.row]
        let userViewModel = UserViewModel(user: user, followUseCase: folloWUseCase)
        cell.viewModel = userViewModel

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ExplorerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.inSeaerchMode ? viewModel.filterUserList[indexPath.row] : viewModel.userList[indexPath.row]
        router.navigateToUserProfile(user: selectedUser, from: self)
    }
}

// MARK: - UISearchControllerDelegate

extension ExplorerController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.isActive = searchController.isActive
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isActive = searchController.isActive
    }
}

// MARK: - UISearchResultsUpdating

extension ExplorerController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.bindText(text: searchText)

        if !searchText.isEmpty {
            viewModel.isActive = true
            tableView.reloadData()
        }
    }
}

// MARK: - SwiftUI Preview

#Preview {
    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "Test"), followUseCase: MockFollowUseCase())
    let mockRepository = MockUserRepository()
    let mockRouter = MockExplorerRouter()

    VCPreView {
        UINavigationController(
            rootViewController: ExplorerController(
                repository: mockRepository,
                userViewModel: mockUserViewModel,
                router: mockRouter,
                followUseCase: MockFollowUseCase()
            )
        )
    }
    .edgesIgnoringSafeArea(.all)
}
