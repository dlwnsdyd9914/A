//
//  CustomAlertController.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit
import SnapKit
import Then
import SwiftUI

final class CustomAlertController: UIViewController {

    // MARK: - Properties

    private let router: TweetRouterProtocol

     var tableViewHeight: CGFloat {
        let rowHeight: CGFloat = 60
        let cancelButtonHeight: CGFloat = 60
        let spacing: CGFloat = 20

        return CGFloat(viewModel.options.count) * rowHeight + cancelButtonHeight + spacing    }


    // MARK: - View Models

    private let viewModel: ActionSheetViewModel

    // MARK: - UI Components

     let tableView = UITableView()

     lazy var blackView = UIView().then {
        $0.alpha = 0 // 시작은 투명하게 (페이드 인 효과용)
        $0.backgroundColor = UIColor(white: 0, alpha: 0.4) // 검정색 반투명 배경
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        $0.addGestureRecognizer(tap) // 탭하면 ㅂ닫히도록
    }

    private lazy var cancelButton = UIButton(type: .custom).then {
        $0.setTitle("Cancel", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemGroupedBackground
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
    }

    private lazy var footerView = UIView().then {
        $0.addSubview(cancelButton)
        cancelButton.anchor(top: nil, leading: $0.leadingAnchor, trailing: $0.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 0, width: 0, height: 50, centerX: nil, centerY: $0.centerYAnchor)
    }


    // MARK: - Initializer

    init(viewModel: ActionSheetViewModel, router: TweetRouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        // 등장 애니메이션: 배경은 점점 어두워지고, 테이블은 위로 올라옴
        UIView.animate(withDuration: 0.5) {
            self.tableView.transform = .identity // 원래 자리로 이동 (아래서 위로 올라옴)
            self.blackView.alpha = 1 // 배경 뷰 페이드 인
        }
    }

    // MARK: - Selectors

    @objc private func handleDismissal() {
        router.dismissAlert(self, animated: false)

    }

    // MARK: - UI Configurations

    private func configureUI() {
        view.backgroundColor = .clear
    }

    private func configureTableView() {
        view.addSubview(tableView)
        blackView.frame = view.frame

        tableView.snp.makeConstraints({
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(tableViewHeight)
        })

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white // 테스트용 색상
        tableView.rowHeight = 60
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none

        // 셀 등록
        tableView.register(CustomAlertCell.self, forCellReuseIdentifier: CellIdentifier.customAlertCell)

        // 🎯 시작 위치 설정: 화면 아래로 숨겨놓음 (올라올 준비)
        tableView.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)

        // 배경도 투명하게 시작
        self.blackView.alpha = 0
    }

    private func addSubViews() {
        [blackView].forEach({view.addSubview($0)})
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onHandleAction = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        viewModel.onFollowToggled = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }



}

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
    // 필요시 셀 선택 이벤트 처리 가능

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]


        print("DEBUG: Selected option is \(option.description)")


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

    private func dismiss() {
        router.dismissAlert(self, animated: true)
    }
}

#Preview {

    let mockUseCase = MockFollowUseCase()
    let mockRouter = MockTweetRouter()



    let actionSheetViewModel = ActionSheetViewModel(userviewModel: UserViewModel(user: MockUserModel(bio: "Teset", didFollow: true)), useCase: mockUseCase)

    VCPreView {
        CustomAlertController(viewModel: actionSheetViewModel, router: mockRouter)
    }.edgesIgnoringSafeArea(.all)
}
