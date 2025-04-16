//
//  EditProfileHeader.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import Kingfisher

/// 프로필 편집 화면 상단에 위치한 헤더 뷰입니다.
/// - 구성: 현재 프로필 이미지, "프로필 편집" 버튼
/// - 기능: 이미지 변경 요청을 외부로 전달하는 클로저 포함
final class EditProfileHeader: UIView {

    // MARK: - Properties

    /// 프로필 편집 버튼이 눌렸을 때 호출되는 클로저
    var onChangePhotoButtonTapped: (() -> Void)?

    // MARK: - View Models

    private let userViewModel: UserViewModel
    private let viewModel: EditProfileHeaderViewModel

    // MARK: - UI Components

    /// 현재 프로필 이미지를 표시하는 이미지 뷰
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 3.0
    }

    /// "프로필 편집" 버튼
    private lazy var changePhotoButton = UIButton(type: .custom).then {
        $0.setTitle("프로필 편집", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(handleChangePhotoButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    init(userViewModel: UserViewModel, viewModel: EditProfileHeaderViewModel) {
        self.userViewModel = userViewModel
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureUI()
        addsubViews()
        configureConstraints()
        bindViewModel()
        setProfileImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }

    // MARK: - Selectors

    /// "프로필 편집" 버튼 탭 이벤트 처리
    @objc private func handleChangePhotoButtonTapped() {
        onChangePhotoButtonTapped?()
    }

    // MARK: - UI Configurations

    private func configureUI() {
        backgroundColor = .backGround
    }

    /// 서브뷰 추가
    private func addsubViews() {
        [profileImageView, changePhotoButton].forEach({ addSubview($0) })
    }

    /// 전체 오토레이아웃 설정 함수
    private func configureConstraints() {
        setProfileImageViewConstraints()
        setChangePhotoButtonConstraints()
    }

    /// 프로필 이미지 뷰 위치 및 사이즈 설정
    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.centerY.equalToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        })
    }

    /// "프로필 편집" 버튼 위치 설정
    private func setChangePhotoButtonConstraints() {
        changePhotoButton.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(8)
        })
    }

    /// userViewModel로부터 초기 프로필 이미지 설정
    private func setProfileImage() {
        profileImageView.kf.setImage(with: userViewModel.profileImageUrl)
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    /// EditProfileHeaderViewModel로부터 이미지 바인딩 처리
    private func bindViewModel() {
        viewModel.onProfileImage = { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
        }
    }
}
