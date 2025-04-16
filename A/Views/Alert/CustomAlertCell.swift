//
//  CustomAlertCell.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit
import SnapKit
import Then

/// 커스텀 액션 시트 내 각 옵션을 표현하는 셀입니다.
/// 아이콘 이미지와 텍스트로 구성되며, ActionSheetOptions 값을 기반으로 UI를 업데이트합니다.
final class CustomAlertCell: UITableViewCell {

    // MARK: - UI Components

    /// 옵션 좌측 아이콘 이미지 뷰
    private let optionImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.image = .twitterLogoBlue  // 기본 테스트용 이미지
    }

    /// 옵션 이름 라벨
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18)
        $0.text = "Test Option" // 기본 텍스트 (초기값)
    }

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        viewAddSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Configurations

    /// 셀 기본 UI 설정 (배경 등)
    private func configureUI() {
        backgroundColor = .white
    }

    /// UI 컴포넌트들을 contentView에 추가
    private func viewAddSubViews() {
        [optionImageView, titleLabel].forEach { contentView.addSubview($0) }
    }

    /// 전체 컴포넌트 제약조건 설정
    private func configureConstraints() {
        setOptionImageViewConstraints()
        setTitleLabelConstraints()
    }

    /// 옵션 이미지 위치 제약
    private func setOptionImageViewConstraints() {
        optionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }
    }

    /// 텍스트 라벨 위치 제약
    private func setTitleLabelConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(optionImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Functions

    /// 셀에 표시될 옵션을 설정합니다.
    /// - Parameter option: ActionSheetOptions 열거형 값
    func configure(with option: ActionSheetOptions) {
        titleLabel.text = option.description
    }
}
