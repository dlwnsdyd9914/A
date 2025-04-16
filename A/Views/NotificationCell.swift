//
//  NotificationCell.swift
//  A
//
//

import UIKit
import Then
import SnapKit
import Kingfisher

/// 알림(Notifications) 리스트 내 단일 셀 구성
/// - 유저 프로필 이미지, 알림 메시지, 팔로우 버튼으로 구성
/// - MVVM 바인딩 방식으로 UI 업데이트
final class NotificationCell: UITableViewCell {

    // MARK: - Properties

    /// 셀 클릭 시 이벤트나 데이터 업데이트를 위한 뷰모델
    var viewModel: NotificationCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    // MARK: - UI Components

    /// 프로필 이미지 뷰 (원형)
    private lazy var profileImageView = UIImageView().then {
        $0.backgroundColor = .backGround
        $0.clipsToBounds = true
    }

    /// 알림 텍스트 라벨 (예: "홍길동님이 회원님을 팔로우했습니다.")
    private let notificationLabel = UILabel().then {
        $0.text = "Some test notification message."
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 13)
    }

    /// 프로필 이미지 + 텍스트를 묶는 수평 스택 뷰
    private lazy var notificationStack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }

    /// 팔로우 상태를 변경할 수 있는 버튼 (팔로우/언팔로우)
    private lazy var followButton = UIButton(type: .custom).then {
        $0.setTitle("Loading", for: .normal)
        $0.setTitleColor(.backGround, for: .normal)
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.backGround.cgColor
        $0.layer.borderWidth = 2
        $0.clipsToBounds = true
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
        fatalError("Storyboard 미사용")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        // 프로필 이미지 및 팔로우 버튼 라운딩
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        followButton.layer.cornerRadius = followButton.frame.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.kf.cancelDownloadTask()
        viewModel?.onFollowStatusCheck = nil
        viewModel = nil
    }

    // MARK: - Selectors

    /// 팔로우 버튼 탭 시 뷰모델 액션 호출
    @objc private func handleFollowButtonTApped() {
        viewModel?.followButtonTapped()
    }

    // MARK: - UI Configurations

    /// 기본 셀 UI 세팅
    private func configureUI() {
        backgroundColor = .white
        selectionStyle = .none
    }

    /// 컴포넌트들을 contentView에 추가
    private func addSubViews() {
        [notificationStack, followButton].forEach { contentView.addSubview($0) }
    }

    /// 오토레이아웃 설정
    private func configureConstraints() {
        setProfileImageViewConstraints()
        setNotifciationStackConstraints()
        setFollowButtonConstraints()
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(48)
        }
    }

    private func setNotifciationStackConstraints() {
        notificationStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalTo(followButton.snp.leading).offset(12)
            $0.centerY.equalToSuperview()
        }
    }

    private func setFollowButtonConstraints() {
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 100, height: 32))
        }
    }


    // MARK: - Bind ViewModels

    /// 뷰모델에서 UI 업데이트를 위한 바인딩 처리
    private func bindViewModel() {
        guard let viewModel else { return }

        // 초기 데이터 세팅
        DispatchQueue.main.async { [weak self, weak vm = viewModel] in
            guard let self,
                  let vm else { return }
            self.profileImageView.kf.setImage(with: URL(string: vm.profileImageUrl))
            self.notificationLabel.text = vm.notificationText
            self.followButton.setTitle(vm.followButtonText, for: .normal)
            self.followButton.isHidden = vm.shouldHideFollowButton
        }

        // 팔로우 상태 변경 시 텍스트 업데이트
        viewModel.onFollowStatusCheck = { [weak self] followStatus in
            guard let self else { return }
            DispatchQueue.main.async {
                self.followButton.setTitle(followStatus, for: .normal)
            }
        }
    }
}
