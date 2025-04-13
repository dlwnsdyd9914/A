//
//  NotificationCell.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit
import Then
import SnapKit
import Kingfisher

final class NotificationCell: UITableViewCell {

    // MARK: - Properties

    // MARK: - View Models
    var viewModel: NotificationCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    // MARK: - UI Components

    private lazy var profileImageView = UIImageView().then {
        $0.backgroundColor = .backGround
        $0.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        tap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true

        $0.addGestureRecognizer(tap)
    }

    private let notificationLabel = UILabel().then {
        $0.text = "Some test notification message."
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var notificationStack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }

    private lazy var followButton = UIButton(type: .custom).then {
        $0.setTitle("Loading", for: .normal)
        $0.setTitleColor(.backGround, for: .normal)
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.backGround.cgColor
        $0.layer.borderWidth = 2
        $0.addTarget(self, action: #selector(handleFollowButtonTApped), for: .touchUpInside)
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureUI()
        addSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }


    // MARK: - Selectors

    @objc private func handleProfileImageTapped() {

    }

    @objc private func handleFollowButtonTApped() {

    }

    // MARK: - UI Configurations


    private func configureUI() {
        backgroundColor = .white
        selectionStyle = .none
    }

    private func addSubViews() {
        [notificationStack].forEach({contentView.addSubview($0)})
    }

    private func configureConstraints() {
        setProfileImageViewConstraints()
        setNotifciationStackConstraints()
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.size.equalTo(48)
        })
    }

    private func setNotifciationStackConstraints() {
        notificationStack.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        })
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        guard let viewModel else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.profileImageView.kf.setImage(with: URL(string: viewModel.profileImageUrl))
            self.notificationLabel.text = viewModel.notificationText
            self.followButton.setTitle(viewModel.followButtonText, for: .normal)
            self.followButton.isHidden = viewModel.shouldHideFollowButton
        }

    }


}
