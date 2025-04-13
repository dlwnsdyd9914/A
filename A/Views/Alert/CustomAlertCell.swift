//
//  CustomAlertCell.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit
import SnapKit
import Then

final class CustomAlertCell: UITableViewCell {

    func configure(with option: ActionSheetOptions) {
        titleLabel.text = option.description
    }


    private let optionImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.image = .twitterLogoBlue
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18)
        $0.text = "Test Option"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        viewAddSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    private func configureUI() {
        backgroundColor = .white
    }

    private func viewAddSubViews() {
        [optionImageView, titleLabel].forEach({contentView.addSubview($0)})
    }

    private func configureConstraints() {
        setOptionImageViewConstraints()
        setTitleLabelConstraints()
    }

    private func setOptionImageViewConstraints() {
        optionImageView.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        })
    }

    private func setTitleLabelConstraints() {
        titleLabel.snp.makeConstraints({
            $0.leading.equalTo(optionImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        })
    }

}
