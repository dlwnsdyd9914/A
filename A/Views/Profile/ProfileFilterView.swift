//
//  ProfileFilterView.swift
//  
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class ProfileFilterView: UIView {


    // MARK: - Properties

    weak var delegate: ProfileFilterViewDelegate?

    // MARK: - View Models

    private let viewModel = ProfileFilterViewModel()



    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        return collectionView
   }()

    private let underLineView = UIView().then {
        $0.backgroundColor = .backGround
    }



    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(underLineView)
        underLineView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: frame.width / 3, height: 2, centerX: nil, centerY: nil)
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureUI() {
        backgroundColor = .red
    }

    private func configureCollectionView() {
        self.addSubview(collectionView)

        collectionView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: CellIdentifier.profileFilterCell)


    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

}

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.profileFilterCell, for: indexPath) as? ProfileFilterCell else {
            return UICollectionViewCell()
        }
        let filterOption = viewModel.filterOptions[indexPath.item]
        let isSelected = (indexPath.item == viewModel.selectedIndex)
        cell.viewModel = ProfileFilterItemViewModel(filterOption: filterOption, isSelected: isSelected)
        return cell
    }
}

extension ProfileFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndex = indexPath.item  
            delegate?.filterView(view: self, didSelect: viewModel.filterOptions[indexPath.item])
        UIView.animate(withDuration: 0.3) {
            self.underLineView.frame.origin.x = collectionView.cellForItem(at: indexPath)?.frame.origin.x ?? 0
        }

        collectionView.reloadData()
    }
}

extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height)
    }
}
