//
//  TweetCell.swift
//  A
//
//

import UIKit
import Kingfisher
import SnapKit
import Then
import ActiveLabel

/// 개별 트윗을 나타내는 UICollectionViewCell입니다.
/// - MVVM 구조 기반으로 TweetViewModel에 바인딩되며, 사용자 인터랙션(프로필 탭/좋아요/댓글 등)을 처리합니다.
/// - 구성: 프로필 이미지, 유저 정보, 본문 텍스트, 리플 대상 유저, 인터랙션 버튼들
final class TweetCell: UICollectionViewCell {

    // MARK: - View Models

    /// 셀에 표시될 트윗 데이터를 보유한 뷰모델
    var viewModel: TweetViewModel? {
        didSet {
            guard let viewModel else { return }
            bindViewModel(viewModel: viewModel)
        }
    }

    /// 프로필 이미지 탭 시 호출되는 클로저
    var onProfileImageViewTapped: (() -> Void)?

    /// 댓글 버튼 탭 시 호출되는 클로저
    var onCommentButtonTapped: (() -> Void)?

    // MARK: - UI Components

    /// 유저의 프로필 이미지 뷰
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

    /// 유저 이름 및 유저네임을 나타내는 라벨
    private let infoLabel = UILabel().then {
        $0.text = "Test @test"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 트윗 본문을 나타내는 라벨 (멘션/해시태그 자동 인식)
    private let captionLabel = ActiveLabel().then {
        $0.text = "Some test caption"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.mentionColor = .backGround
        $0.hashtagColor = .backGround
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 셀 하단 구분선
    private let underLineView = UIView().then {
        $0.backgroundColor = .lightGray
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// infoLabel + captionLabel 을 수직으로 배치하는 스택뷰
    private lazy var labelStackView = UIStackView(arrangedSubviews: [infoLabel, captionLabel]).then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 댓글 버튼
    private lazy var commentButton = UIButton(type: .custom).then {
        $0.setImage(.comment, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 리트윗 버튼 (기능 미구현)
    private lazy var retweetButton = UIButton(type: .custom).then {
        $0.setImage(.retweet, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleRetweetButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 좋아요 버튼
    private lazy var likeButton = UIButton(type: .custom).then {
        $0.setImage(.like, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 공유 버튼 (기능 미구현)
    private lazy var shareButton = UIButton(type: .custom).then {
        $0.setImage(.shareImage, for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 댓글/리트윗/좋아요/공유 버튼을 수평 배치한 스택뷰
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 4
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 리플 대상 유저 정보를 표시하는 라벨
    private let replyLabel = ActiveLabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
        $0.text = "→ replying to @Test"
        $0.mentionColor = .backGround
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 프로필 이미지 + 본문을 수평으로 정렬한 스택뷰
    private lazy var imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStackView]).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .top
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// replyLabel + imageCaptionStack을 수직으로 정렬한 전체 스택
    private lazy var stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .top
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addsubViews()
        configureConstraints()
        conigureMentionHandler()
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

    /// 프로필 이미지 탭 시 호출
    @objc private func handleProfileImageTapped() {
        onProfileImageViewTapped?()
    }

    /// 댓글 버튼 탭 시 호출
    @objc private func handleCommentButton() {
        viewModel?.handleCommentButton()
    }

    /// 리트윗 버튼 탭 시 호출 (기능 미구현)
    @objc private func handleRetweetButton() {
        //        viewModel?.handleRetweetButton()
    }

    /// 좋아요 버튼 탭 시 호출
    @objc private func handleLikeButton() {
        viewModel?.handleLikeButton()
    }

    /// 공유 버튼 탭 시 호출 (기능 미구현)
    @objc private func handleShareButton() {
        //        viewModel?.handleShareButton()
    }

    // MARK: - UI Configurations

    /// 셀 기본 배경색 설정
    private func configureUI() {
        backgroundColor = .white
    }

    /// 셀에 컴포넌트 추가
    private func addsubViews() {
        [stack, buttonStackView, underLineView].forEach({ contentView.addSubview($0) })
    }

    /// 오토레이아웃 설정 진입점
    private func configureConstraints() {
        setLabelStackViewConstraints()
        setButtonStackViewConstraints()
        setUnderlineViewconstraints()
    }

    /// replyLabel + 본문을 담은 전체 stack 위치 설정
    private func setLabelStackViewConstraints() {
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: buttonStackView.topAnchor, paddingTop: 4, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    /// 버튼 스택 위치 설정
    private func setButtonStackViewConstraints() {
        buttonStackView.anchor(top: stack.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, paddingTop: 8, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 8, width: 0, height: 0, centerX: centerXAnchor, centerY: nil)
    }

    /// 하단 구분선 위치 설정
    private func setUnderlineViewconstraints() {
        underLineView.anchor(top: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 1, centerX: nil, centerY: nil)
    }

    /// 좋아요 버튼 이미지 갱신
    private func configureLikeButton(didLike: Bool) {
        self.likeButton.setImage(viewModel?.likeButtonImage, for: .normal)
    }

    // MARK: - Bind ViewModels

    /// TweetViewModel 바인딩: 데이터 및 이벤트 처리
    private func bindViewModel(viewModel: TweetViewModel) {
            infoLabel.attributedText = viewModel.infoLabel
            captionLabel.text = viewModel.caption
            profileImageView.kf.setImage(with: viewModel.profileImageUrl)
            replyLabel.isHidden = viewModel.shouldHideReplyLabel
            replyLabel.text = viewModel.replyText


        viewModel.onTweetLikes = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.likeButton.setImage(viewModel.likeButtonImage, for: .normal)
            }
        }

        viewModel.ondidLike = { [weak self] didLike in
            guard let self else { return }
            configureLikeButton(didLike: didLike)
        }

        viewModel.didLike()
    }

    /// 멘션 텍스트 탭 시 동작 처리
    private func conigureMentionHandler() {
        captionLabel.handleMentionTap { [weak self] username in
            guard let self else { return }
            self.viewModel?.handleMention(username: username)
        }
    }
}

