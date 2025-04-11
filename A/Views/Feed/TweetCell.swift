//
//  TweetCell.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit
import Kingfisher
import Then

final class TweetCell: UICollectionViewCell {

    // MARK: - Properties

    // MARK: - View Models

    // MARK: - UI Components

    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        tap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
        $0.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 48),
            $0.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private let captionLabel = UILabel().then {
        $0.text = "Some test caption"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
    }

    private let infoLabel = UILabel().then {
        $0.text = "Test @test"
    }

    private let underLineView = UIView().then {
        $0.backgroundColor = .lightGray
    }

    private lazy var labelStackView = UIStackView(arrangedSubviews: [infoLabel, captionLabel]).then {
        $0.axis = .vertical
        $0.spacing = 4

    }

    private lazy var commentButton = UIButton(type: .custom).then {
        $0.setImage(.comment, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
    }

    private lazy var retweetButton = UIButton(type: .custom).then {
        $0.setImage(.retweet, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleRetweetButton), for: .touchUpInside)
    }

    private lazy var likeButton = UIButton(type: .custom).then {
        $0.setImage(.like, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
    }

    private lazy var shareButton = UIButton(type: .custom).then {
        $0.setImage(.shareImage, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
    }

    private lazy var buttonStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 4
    }

    private let replyLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.text = "→ replying to @Test"

    }


    private lazy var imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStackView]).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .top

    }

    private lazy var stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .top
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addsubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2

    }

    // MARK: - Selectors

    @objc private func handleProfileImageTapped() {
        //        viewModel?.handleProfileImageTapped()
    }

    @objc private func handleCommentButton() {
        //        viewModel?.handleCommentButton()
    }

    @objc private func handleRetweetButton() {
        //        viewModel?.handleRetweetButton()
    }

    @objc private func handleLikeButton() {
        //        viewModel?.handleLikeButton()
    }

    @objc private func handleShareButton() {
        //        viewModel?.handleShareButton()
    }

    // MARK: - UI Configurations

    private func configureUI() {
        backgroundColor = .white
    }

    private func addsubViews() {
        [stack, buttonStackView, underLineView].forEach({ contentView.addSubview($0) })
    }


    private func configureConstraints() {
        setLabelStackViewConstraints()
        setButtonStackViewConstraints()
        setUnderlineViewconstraints()
    }



    private func setLabelStackViewConstraints() {
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: buttonStackView.topAnchor, paddingTop: 4, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func setButtonStackViewConstraints() {
        buttonStackView.anchor(top: stack.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, paddingTop: 8, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 8, width: 0, height: 0, centerX: centerXAnchor, centerY: nil)
    }

    private func setUnderlineViewconstraints() {
        underLineView.anchor(top: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 1, centerX: nil, centerY: nil)
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels



}
