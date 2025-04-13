//
//  ProfileFilterView.swift
//  
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class ProfileFilterView: UIView {


    // MARK: - Properties

    // MARK: - View Models

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        return collectionView
   }()


    // MARK: - Initializer

    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureUI() {
        view.backgroundColor = .red
    }

    private func configureCollectionView() {
        self.addSubview(collectionView)

        collectionView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: Cell.profileFilterCell)


    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

}

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.profileFilterCell, for: indexPath) as? ProfileFilterCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

extension ProfileFilterView: UICollectionViewDelegate {

}
