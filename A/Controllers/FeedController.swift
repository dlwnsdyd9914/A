//
//  FeedController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

class FeedController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    // MARK: - UI Components

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        let apperacne = UINavigationBarAppearance()

        navigationController?.navigationBar.scrollEdgeAppearance = apperacne
    }

    private func configureUI() {
        view.backgroundColor = .white
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels



}
