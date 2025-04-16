//
//  CustomAlertController.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import SwiftUI

/// 트윗 관련 액션을 보여주는 커스텀 알림 컨트롤러
/// - 기능: 팔로우, 언팔로우, 리포트, 삭제 등의 ActionSheet 역할 수행
/// - 디자인: 테이블뷰 기반으로 구성, 하단에서 슬라이드 업 형식의 인터랙션 제공
/// - 의존성: 라우터(TweetRouter)와 액션 처리 ViewModel(ActionSheetViewModel)을 통해 동작
final class CustomAlertController: UIViewController {

    /// MARK: - Dependencies

    /// 화면 종료 및 외부 동작 처리를 담당하는 라우터
    private let router: TweetRouterProtocol

    /// 전체 알림 뷰 높이 계산
    var tableViewHeight: CGFloat {
        let rowHeight: CGFloat = 60
        let cancelButtonHeight: CGFloat = 60
        let spacing: CGFloat = 20

        return CGFloat(viewModel.options.count) * rowHeight + cancelButtonHeight + spacing
    }

    // MARK: - View Models

    /// 현재 유저 상태 및 알림 옵션들을 관리하고 액션을 실행하는 뷰모델
    private let viewModel: ActionSheetViewModel

    // MARK: - UI Components

    /// 옵션을 보여주는 테이블 뷰
    let tableView = UITableView()

    /// 전체 배경을 어둡게 처리하는 뷰 (탭 시 알림 닫힘)
    lazy var blackView = UIView().then {
        $0.alpha = 0
        $0.backgroundColor = UIColor(white: 0, alpha: 0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        $0.addGestureRecognizer(tap)
    }

    /// 아래쪽 'Cancel' 버튼
    private lazy var cancelButton = UIButton(type: .custom).then {
        $0.setTitle("Cancel", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemGroupedBackground
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
    }

    /// 테이블 뷰 푸터에 들어가는 버튼 컨테이너
    private lazy var footerView = UIView().then {
        $0.addSubview(cancelButton)
        cancelButton.anchor(
            top: nil,
            leading: $0.leadingAnchor,
            trailing: $0.trailingAnchor,
            bottom: nil,
            paddingTop: 0,
            paddingLeading: 12,
            paddingTrailing: 12,
            paddingBottom: 0,
            width: 0,
            height: 50,
            centerX: nil,
            centerY: $0.centerYAnchor
        )
    }

    // MARK: - Initializer

    /// DI 기반 생성자: ViewModel 및 Router 주입
    init(viewModel: ActionSheetViewModel, router: TweetRouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addSubViews()
        configureTableView()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 등장 애니메이션
        UIView.animate(withDuration: 0.5) {
            self.tableView.transform = .identity
            self.blackView.alpha = 1
        }
    }

    // MARK: - Selectors

    /// 바깥 영역 또는 취소 버튼 탭 시 알림 닫기
    @objc private func handleDismissal() {
        router.dismissAlert(self, animated: false)
    }

    // MARK: - UI Configurations

    /// 배경 투명 처리
    private func configureUI() {
        view.backgroundColor = .clear
    }

    /// 테이블뷰 설정 및 레이아웃
    private func configureTableView() {
        view.addSubview(tableView)
        blackView.frame = view.frame

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(tableViewHeight)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.rowHeight = 60
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(CustomAlertCell.self, forCellReuseIdentifier: CellIdentifier.customAlertCell)

        tableView.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        self.blackView.alpha = 0
    }

    /// 검은 배경 추가
    private func addSubViews() {
        [blackView].forEach { view.addSubview($0) }
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    /// 뷰모델 상태 변경에 따라 테이블뷰 업데이트
    private func bindViewModel() {
        viewModel.onHandleAction = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onFollowToggled = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension CustomAlertController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.customAlertCell, for: indexPath) as? CustomAlertCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        let option = viewModel.options[indexPath.row]
        cell.configure(with: option)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CustomAlertController: UITableViewDelegate {
    /// 푸터뷰 반환 (Cancel 버튼 포함)
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    /// 셀 선택 시 액션 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]

        switch option {
        case .follow, .unfollow:
            viewModel.handleAction()
            dismiss()
        case .report:
            print("DEBUG: Selected option is Report")
            dismiss()
        case .delete:
            break
        }
    }

    /// 공통 dismiss 로직
    private func dismiss() {
        router.dismissAlert(self, animated: true)
    }
}


#Preview {

    let mockUseCase = MockFollowUseCase()
    let mockRouter = MockTweetRouter()
    let mockFollowUseCase = MockFollowUseCase()



    let actionSheetViewModel = ActionSheetViewModel(userviewModel: UserViewModel(user: MockUserModel(bio: "Teset", didFollow: true), followUseCase: mockFollowUseCase), useCase: mockUseCase)

    VCPreView {
        CustomAlertController(viewModel: actionSheetViewModel, router: mockRouter)
    }.edgesIgnoringSafeArea(.all)
}
