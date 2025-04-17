//
//  UserCell.swift
//  A
//
//

import UIKit
import SnapKit
import Then
import Kingfisher

/// 유저 정보를 보여주는 테이블 뷰 셀입니다.
/// - 구성: 유저의 프로필 이미지, 유저네임, 풀네임 표시
/// - 기능: 뷰모델을 통해 UI 요소 바인딩
final class UserCell: UITableViewCell {

    // MARK: - View Models

    /// 유저 정보를 담은 뷰모델 - 값 설정 시 자동으로 바인딩
    var viewModel: UserViewModel? {
        didSet {
            guard let viewModel else { return }
            bindViewModel(viewModel: viewModel)
        }
    }

    // MARK: - UI Components

    /// 유저 프로필 이미지 뷰
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    /// 유저 유저네임 레이블
    private let usernameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.text = "Username"
    }

    /// 유저 풀네임 레이블
    private let fullnameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Fullname"
    }

    /// 유저네임 + 풀네임 수직 스택뷰
    private lazy var labelStack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fillEqually
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        viewAddSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 사용 안함")
    }

    // MARK: - Life Cycles

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = 32 / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - UI Configurations

    /// UI 서브뷰 추가
    private func viewAddSubViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(labelStack)
    }

    /// 전체 레이아웃 설정 진입점
    private func configureConstraints() {
        profileImageViewConstraints()
        labelStackConstraints()
    }


    private func profileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(32)
        })
    }


    private func labelStackConstraints() {
        labelStack.snp.makeConstraints({
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        })
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels
    
    /// 뷰모델 값에 따라 UI 요소 갱신
    func bindViewModel(viewModel: UserViewModel) {
        self.profileImageView.kf.setImage(with: viewModel.profileImageUrl)
        self.usernameLabel.text = viewModel.username
        self.fullnameLabel.text = viewModel.fullname

    }
}
