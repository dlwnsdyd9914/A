//
//  ProfileHeader.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Then
import Kingfisher

/// 프로필 화면 상단에 표시되는 사용자 정보 헤더입니다.
/// 사용자 프로필 이미지, 이름, 아이디, 바이오, 팔로우 수, 필터 바 등을 구성합니다.
final class ProfileHeader: UICollectionReusableView {


    var viewModel: ProfileHeaderViewModel? {
        didSet {
            bindViewModel()
        }
    }

    // MARK: - Properties

    var onBackButtonTap: (() -> Void)?
    var onEditProfileButtonTap: (() -> Void)?

    weak var delegate: ProfileHeaderDelegate?

    // MARK: - UI Components

    private let filterBar = ProfileFilterView()

    private lazy var backButton = UIButton(type: .custom).then {
        $0.setImage(.backImage.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private let containerView = UIView().then {
        $0.backgroundColor = .backGround
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .lightGray
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 4
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private lazy var editFollowButton = UIButton(type: .custom).then {
        $0.setTitle("Loading", for: .normal)
        $0.layer.borderColor = UIColor.backGround.cgColor
        $0.layer.borderWidth = 1.25
        $0.setTitleColor(.backGround, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleEditFollowButton), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private let fullnameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "Fullname"
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private let usernameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.text = "Username"
        $0.textColor = .lightGray
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private let bioLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.text = "TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestT"
        $0.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private lazy var userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel, bioLabel]).then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillProportionally
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private lazy var followingLabel = UILabel().then {
        $0.text = "0 following"
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFollowing))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private lazy var follwerLabel = UILabel().then {
        $0.text = "0 followers"
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFollwer))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    private lazy var followStack = UIStackView(arrangedSubviews: [followingLabel, follwerLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.translatesAutoresizingMaskIntoConstraints = false

    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        self.backgroundColor = .white
        addSubviews()
        configureConstraints()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2

        editFollowButton.clipsToBounds = true
        editFollowButton.layer.cornerRadius = editFollowButton.frame.height / 2

        // ✅ 핵심 라인
            bioLabel.preferredMaxLayoutWidth = bioLabel.frame.width
    }

    // MARK: - Selectors

    @objc private func handleBackButton() {
        onBackButtonTap?()
    }

    @objc private func handleEditFollowButton() {
        viewModel?.followToggled()
    }

    @objc private func handleFollowing() {
        // 팔로잉 라벨 탭 처리
    }

    @objc private func handleFollwer() {
        // 팔로워 라벨 탭 처리
    }

    // MARK: - UI Configurations

    private func addSubviews() {
        [backButton, containerView, profileImageView, editFollowButton,
         userDetailStack, followStack, filterBar].forEach { addSubview($0) }

        bringSubviewToFront(backButton)
    }

    private func configureConstraints() {
        setBackButtonConstraints()
        setContainerViewConstraints()
        setProfileImageViewConstraints()
        setEditFollowButtonConstraints()
        setUserDetailStackConstraints()
        setFollowStackConstraints()
        setFilterBarConstraints()
    }

    private func setBackButtonConstraints() {
        backButton.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 42, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 30, height: 30, centerX: nil, centerY: nil)
    }

    private func setContainerViewConstraints() {
        containerView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 108, centerX: nil, centerY: nil)
    }

    private func setProfileImageViewConstraints() {
        profileImageView.anchor(top: containerView.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: -24, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 80, height: 80, centerX: nil, centerY: nil)
    }

    private func setEditFollowButtonConstraints() {
        editFollowButton.anchor(top: containerView.bottomAnchor, leading: nil, trailing: trailingAnchor, bottom: nil, paddingTop: 12, paddingLeading: 0, paddingTrailing: 12, paddingBottom: 0, width: 100, height: 36, centerX: nil, centerY: nil)
    }

    private func setUserDetailStackConstraints() {
        userDetailStack.anchor(top: profileImageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: followStack.topAnchor, paddingTop: 8, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func setFollowStackConstraints() {
        followStack.anchor(top: userDetailStack.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: filterBar.topAnchor, paddingTop: 8, paddingLeading: 12, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func setFilterBarConstraints() {
        filterBar.anchor(top: followStack.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 50, centerX: nil, centerY: nil)
    }


    // MARK: - Functions
    private func updateFollowButton(status: String) {
        self.editFollowButton.setTitle(status, for: .normal)
    }

    // 추후 뷰모델 바인딩이나 내부 상태 업데이트 함수 추가 가능

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        guard let viewModel else { return }


            self.bioLabel.text = viewModel.bio
            self.usernameLabel.text = viewModel.username
            self.fullnameLabel.text = viewModel.fullname
            self.profileImageView.kf.setImage(with: viewModel.profileImageUrl)
            self.editFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)


        viewModel.onFollowStatusCheck = { [weak self] followStatus in
            guard let self else { return }
            DispatchQueue.main.async {
                if viewModel.getUser().isCurrentUser {
                    self.editFollowButton.setTitle("Edit Profile", for: .normal)
                } else {
                    self.editFollowButton.setTitle(followStatus, for: .normal)
                }
            }
        }
        viewModel.onFollowLabelCount = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.followingLabel.attributedText = viewModel.followingString
                self.follwerLabel.attributedText = viewModel.followerString
            }
        }

        viewModel.checkingFollow()
        viewModel.getFollowCount()
    }
}


extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(view: ProfileFilterView, didSelect filter: FilterOption) {
        delegate?.profileHeader(self, didSelect: filter)
    }


}
