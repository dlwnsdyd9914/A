//
//  TweetHeader.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit
import Then
import Kingfisher
final class TweetHeader: UICollectionReusableView {

    var viewModel: TweetHeaderViewModelProtocol? {
        didSet {
            guard let viewModel else { return }
            bindViewModel(viewModel: viewModel)

        }
    }

    private lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .lightGray
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImage))
        profileImageTap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(profileImageTap)
    }

    private let fullnameLabel = UILabel().then {
        $0.text = "Fullname"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16)
    }

    private let usernameLabel = UILabel().then {
        $0.text = "Eddie Slimon @Celine"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
    }



    private lazy var labelStackView = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel]).then {
        $0.axis = .vertical
        $0.spacing = -6
    }

    private lazy var stack = UIStackView(arrangedSubviews: [profileImageView, labelStackView]).then {
        $0.spacing = 12
    }

    private let captionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
        $0.numberOfLines = 0  // 🔥 여러 줄 표시 허용
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)  // 🔥 필요 이상으로 커지지 않도록 설정
        $0.setContentCompressionResistancePriority(.required, for: .vertical) // 🔥 최소 높이 보장
    }


    private let dateLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .left
        $0.text = "6:33 PM - 3/06/2025"
    }

    private lazy var retweetsLabel = UILabel().then {
        $0.text = "2 Retweets"
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var likesLabel = UILabel().then {
        $0.text = "0 Likes"
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var statsView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let divider1 = UIView()
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.backgroundColor = .systemGroupedBackground
        $0.addSubview(divider1)
        divider1.anchor(top: $0.topAnchor, leading: $0.leadingAnchor, trailing: $0.trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 1.0, centerX: nil, centerY: nil)
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        $0.addSubview(stack)
        stack.anchor(top: nil, leading: $0.leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: $0.centerYAnchor)

        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        $0.addSubview(divider2)
        divider2.anchor(top: nil, leading: $0.leadingAnchor, trailing: $0.trailingAnchor, bottom: $0.bottomAnchor, paddingTop: 0, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 1.0, centerX: nil, centerY: nil)
    }


    private lazy var optionButton = UIButton(type: .custom).then {
        $0.tintColor = .lightGray
        $0.setImage(#imageLiteral(resourceName: "down_arrow_24pt"), for: .normal)
        $0.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
    }

    private lazy var commentButton = UIButton(type: .custom).then {
        $0.setImage(.commentImage, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
    }

    private lazy var retweetButton = UIButton(type: .custom).then {
        $0.setImage(.retweetImage, for: .normal)
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

    private let underLineView = UIView().then {
        $0.backgroundColor = .red
    }

    private lazy var actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton]).then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .fillEqually
    }

    @objc private func handleProfileImage() {
        print(#function)
    }

    @objc private func showActionSheet() {
        viewModel?.showActionSheet()
    }

    @objc private func handleCommentButton() {
        print(#function)
    }

    @objc private func handleRetweetButton() {
        print(#function)
    }

    @objc private func handleLikeButton() {
        print(#function)
    }

    @objc private func handleShareButton() {
        print(#function)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        setup()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func layoutSubviews() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        // 🔥 강제로 레이아웃 업데이트
          self.layoutIfNeeded()

          // 🔥 captionLabel이 레이아웃을 넘어가지 않도록 설정
        captionLabel.preferredMaxLayoutWidth = captionLabel.frame.width
    }

    private func setup() {
        self.addSubview(stack)
        self.addSubview(captionLabel)
        self.addSubview(dateLabel)
        self.addSubview(optionButton)
        self.addSubview(statsView)
        self.addSubview(actionStack)
    }

    private func configureConstraints() {
        profileImageViewConstraints()
        stackConstraints()
        captionLabelConstraints()
        dateLabelConstraints()
        optionButtonConstraints()
        statsViewConstraints()
        actionStackConstraints()
    }

    private func profileImageViewConstraints() {
        profileImageView.anchor(top: nil, leading: nil, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 48, height: 48, centerX: nil, centerY: nil)
    }

    private func stackConstraints() {
        stack.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 16, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func captionLabelConstraints() {
        captionLabel.anchor(top: stack.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: dateLabel.topAnchor, paddingTop: 12, paddingLeading: 16, paddingTrailing: 16, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)

    }

    private func dateLabelConstraints() {
        dateLabel.anchor(top: captionLabel.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: statsView.topAnchor, paddingTop: 20, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func optionButtonConstraints() {
        optionButton.anchor(top: nil, leading: nil, trailing: trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 8, paddingBottom: 0, width: 24, height: 24, centerX: nil, centerY: stack.centerYAnchor)
    }

    private func statsViewConstraints() {
        statsView.anchor(top: dateLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: actionStack.topAnchor, paddingTop: 20, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 8, width: 0, height: 40, centerX: nil, centerY: nil)
    }

    private func actionStackConstraints() {
        actionStack.anchor(top: nil, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 12, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func bindViewModel(viewModel: TweetHeaderViewModelProtocol) {

        self.fullnameLabel.text = viewModel.fullname
        self.usernameLabel.text = viewModel.username
        self.profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        self.dateLabel.text = viewModel.headerTimestamp
        self.retweetsLabel.attributedText = viewModel.retweetAttributedString
        self.likesLabel.attributedText = viewModel.retweetAttributedString
        self.captionLabel.text = viewModel.caption
    }
}
