//
//  ProfileFilterCell.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Then
import SnapKit

final class ProfileFilterCell: UICollectionViewCell {

    var viewModel: ProfileFilterItemViewModel? {
        didSet {
            configureCell()
        }
    }

    private let titleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.text = "Test"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubViews() {
        contentView.addSubview(titleLabel)
        setTitleLabelConstraints()
    }

    private func setTitleLabelConstraints() {
        titleLabel.snp.makeConstraints({
            $0.centerX.centerY.equalToSuperview()
        })
    }

    private func configureCell() {
        guard let viewModel else { return }
        titleLabel.text = viewModel.selectedFilterOption.description
        updateUI()

        // ✅ 뷰모델의 `onFilterStatus`를 통해 UI 업데이트 감지
        viewModel.onFilterStatus = { [weak self] isSelected in
            self?.updateUI()
        }
    }

    private func updateUI() {
        guard let viewModel else { return }
        titleLabel.font = viewModel.isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = viewModel.isSelected ? UIColor.backGround : .lightGray
    }
}
