//
//  EditProfileController.swift
//  A
//
//

import UIKit
import SnapKit
import Then

/// 사용자 프로필 편집 화면 컨트롤러
/// - MVVM 아키텍처 기반으로 상태 관리 및 유저 정보 업데이트 처리
/// - 헤더에 이미지 변경 기능 포함 (UIImagePicker 사용)
/// - 편집 완료 후 Notification 및 클로저를 통해 상태 전파
final class EditProfileController: UIViewController {

    // MARK: - Dependencies (외부 주입 객체)

    /// 화면 전환 및 dismiss 처리를 위한 라우터
    private let router: FeedRouterProtocol

    /// 유저 프로필이 변경되었을 때 상위 컨트롤러에 변경 데이터 전달
    var onProfileEdited: ((UserModelProtocol) -> Void)?

    // MARK: - View Models

    /// 헤더(이미지뷰 포함) 전용 뷰모델
    private let editProfileHeaderViewModel: EditProfileHeaderViewModel

    /// 유저 기본 데이터 관리용 뷰모델
    private let userViewModel: UserViewModel

    /// 편집 로직 전체를 담당하는 핵심 뷰모델
    private let viewModel: EditProfileViewModel

    // MARK: - UI Components

    /// 프로필 편집 폼을 구성하는 테이블뷰
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 프로필 이미지 변경 시 사용하는 이미지 피커
    private lazy var imagePicker = UIImagePickerController().then {
        $0.allowsEditing = true
        $0.delegate = self
    }

    // MARK: - Initializer

    /// ViewModel, HeaderViewModel, Router 등 의존성 주입
    init(router: FeedRouterProtocol, userViewModel: UserViewModel, editProfileHeaderViewModel: EditProfileHeaderViewModel, viewModel: EditProfileViewModel) {
        self.router = router
        self.userViewModel = userViewModel
        self.viewModel = viewModel
        self.editProfileHeaderViewModel = editProfileHeaderViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 편집 타이틀이 보이도록 네비게이션바 활성화
        navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 디폴트 appearance 복구
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        bindViewModel()
    }

    // MARK: - Selectors

    /// 취소 버튼 클릭 시 화면 종료
    @objc private func handleCancleButtonTapped() {
        router.popNav(from: self)
    }

    /// 완료 버튼 클릭 시 ViewModel을 통해 유저 정보 업데이트
    @objc private func handleDoneButtonTapped() {
        viewModel.updateUser()
    }

    // MARK: - UI Configurations

    /// 네비게이션바 스타일 및 버튼 구성
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backGround
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        let navBar = navigationController?.navigationBar
        navBar?.scrollEdgeAppearance = appearance
        navBar?.tintColor = .white

        navigationItem.title = "프로필 편집"
    }

    /// 배경 색상 설정
    private func configureUI() {
        view.backgroundColor = .white
    }

    /// 테이블뷰 등록, 헤더 구성, 버튼 바인딩 등 초기 설정
    private func configureTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        configureTableHeaderView()

        tableView.estimatedRowHeight = 48
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: CellIdentifier.editProfileCell)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancleButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    /// 프로필 이미지 및 닉네임 변경이 가능한 헤더 뷰 설정
    private func configureTableHeaderView() {
        let headerView = EditProfileHeader(userViewModel: userViewModel, viewModel: editProfileHeaderViewModel)

        headerView.onChangePhotoButtonTapped = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.present(self.imagePicker, animated: true)
            }
        }

        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180)
        tableView.tableHeaderView = headerView
    }

    // MARK: - Bind ViewModels

    /// ViewModel과 View 간 바인딩 처리
    private func bindViewModel() {
        // 저장 완료 시 알림 및 라우터 종료 처리
        viewModel.onSaveUserDataSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let updatedUser = self.viewModel.user
                self.onProfileEdited?(updatedUser)
                NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
                self.router.popNav(from: self)
            }
        }

        // 수정 감지 시 완료 버튼 활성화
        viewModel.onDoneButtonEnalbed = { [weak self] check in
            guard let self else { return }
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = check
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension EditProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.editProfileOption.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.editProfileCell, for: indexPath) as? EditProfileCell else {
            return UITableViewCell()
        }

        guard let options = EditProfileOption(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let editProfileCellViewModel = EditProfileCellViewModel(option: options, viewModel: viewModel)
        cell.viewModel = editProfileCellViewModel
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditProfileController: UITableViewDelegate {}

// MARK: - UIImagePickerControllerDelegate

extension EditProfileController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }

        // 헤더 및 ViewModel 모두에 이미지 바인딩
        editProfileHeaderViewModel.bindProfileImage(image: profileImage)
        viewModel.currentProfileImage = profileImage

        // 변경 사항 유무 체크
        viewModel.checkForChanges()

        // 피커 닫기
        router.dismiss(from: self)
    }
}

// MARK: - UINavigationControllerDelegate

extension EditProfileController: UINavigationControllerDelegate {}
