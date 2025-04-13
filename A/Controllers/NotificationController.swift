//
//  NotificationController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import SnapKit
import Then
import SwiftUI

final class NotificationController: UIViewController {

    // MARK: - Properties


    // MARK: - View Models

    private let useCase: NotificationUseCaseProtocol

    private let viewModel: NotificationViewModel

    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Initializer

    init(useCase: NotificationUseCaseProtocol) {
        self.useCase = useCase
        self.viewModel = NotificationViewModel(useCase: useCase)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        bindViewModel()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        self.navigationItem.title = "알림"
    }

    private func configureUI() {
        self.view.backgroundColor = .white
    }

    private func configureTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        tableView.rowHeight = 60
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(NotificationCell.self, forCellReuseIdentifier: CellIdentifier.notificationCell)
    }


    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onFeatchNotification = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        viewModel.fetchNotifications()
    }




}

extension NotificationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.notificationCell, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }
        let item = viewModel.notifications[indexPath.row]
        let notificationCellViewModel = NotificationCellViewModel(item: item)
        cell.viewModel = notificationCellViewModel
        return cell
    }
}

extension NotificationController: UITableViewDelegate {

}

#Preview {

    let mockUseCase = MockNotificationUseCase()
    VCPreView {
        UINavigationController(rootViewController: NotificationController(useCase: mockUseCase))
    }.edgesIgnoringSafeArea(.all)
}
