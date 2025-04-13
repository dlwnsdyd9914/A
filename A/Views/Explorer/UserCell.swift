//
//  UserCell.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class UserCell: UITableViewCell {

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    private let usernameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.text = "Username"
    }

    private let fullnameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Fullname"
    }

    private lazy var labelStack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fillEqually
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        viewAddSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }



    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func viewAddSubViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(labelStack)
    }

    private func configureConstraints() {
        profileImageViewConstraints()
        labelStackConstraints()
    }

    private func profileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(32)
        })
        profileImageView.layer.cornerRadius = 32 / 2

    }

    private func labelStackConstraints() {
        labelStack.snp.makeConstraints({
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        })
    }

     func configureUser(viewModel: UserViewModel) {
        profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        usernameLabel.text = viewModel.username
        fullnameLabel.text = viewModel.fullname
    }


}
