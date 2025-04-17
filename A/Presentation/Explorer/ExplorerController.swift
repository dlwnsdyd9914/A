//
//  ExplorerController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import SwiftUI
import SnapKit
import Then

/// 사용자 탐색 화면 (Explorer)
/// - 기능: 사용자 리스트 출력 및 검색
/// - 사용 기술: UIKit, MVVM, UISearchController, SnapKit, Then
final class ExplorerController: UIViewController {

    // MARK: - Properties

    /// 사용자 목록을 보여주는 테이블뷰
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 사용자 검색을 위한 서치 컨트롤러
    private let searchController = UISearchController(searchResultsController: nil)

    private let router: ExplorerRouterProtocol

    private let folloWUseCase: FollowUseCaseProtocol

    private var didRegisterObserver = false




    // MARK: - View Models

    /// 사용자 검색 및 데이터 필터링을 담당하는 뷰모델
    private let viewModel: ExplorerViewModel

    /// 현재 로그인된 사용자 정보
    private let userViewModel: UserViewModel

    // MARK: - Initializer

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

    deinit {
            NotificationCenter.default.removeObserver(self)
        }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = false
        registerNotificationObservers()

        // ✅ 복귀 시 searchController 재적용
        if navigationItem.searchController == nil {
            navigationItem.searchController = searchController
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        configureSearchController()
        bindViewModel()

    }

    // MARK: - Selectors


    @objc private func handleProfileUpdated(_ notification: Foundation.Notification) {
        guard let updateUser = notification.object as? UserModelProtocol else { return }


        self.viewModel.updatedUser(user: updateUser)
        self.tableView.reloadData()
    }

    // MARK: - UI Configurations

    /// 네비게이션 바 설정 (타이틀, 스타일)
    private func configureNavigationBar() {

        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.title = "검색"
    }

    /// 배경 색상 등 초기 UI 설정
    private func configureUI() {
        view.backgroundColor = .white
    }

    /// 테이블뷰 설정 및 레이아웃 구성
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

    /// 서치 컨트롤러 설정
    private func configureSearchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "사용자 검색"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }

    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileUpdated), name: .didUpdateProfile, object: nil)
    }


    // MARK: - Bind ViewModel

    /// 뷰모델과 클로저 바인딩
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
    let diContainer = MockDiContainer()

    VCPreView {
        UINavigationController(rootViewController: ExplorerController(repository: mockRepository, userViewModel: mockUserViewModel, router: mockRouter, followUseCase: MockFollowUseCase()))
    }
    .edgesIgnoringSafeArea(.all)
}
