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

final class ExplorerController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - View Models

    // MARK: - UI Components

    // MARK: - Initializer

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.title = "검색"
    }

    private func configureUI() {
        view.backgroundColor = .white
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels





}


#Preview {



    VCPreView {
        UINavigationController(rootViewController: ExplorerController())
    }.edgesIgnoringSafeArea(.all)
}

