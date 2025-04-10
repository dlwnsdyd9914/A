//
//  InputContainerView.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Then
import SnapKit

/// 이미지와 텍스트필드, 밑줄이 포함된 공통 인풋 UI 컴포넌트입니다.
/// 로그인/회원가입 화면 등에서 재사용 가능한 구조로 설계되어 있습니다.
final class InputContainerView: UIView {

    // MARK: - UI Components

    /// 좌측 아이콘 이미지 뷰
    private let imageView = UIImageView()

    /// 외부에서 주입받는 텍스트필드 (ex: 이메일, 비밀번호 입력 필드)
    private let textField: UITextField

    /// 텍스트필드 하단 구분선 (underline)
    private let underlineView = UIView().then {
        $0.backgroundColor = .underLine
    }

    // MARK: - Initializer

    /// 이미지와 텍스트필드를 외부에서 주입받아 구성
    init(textFieldImage: UIImage, textField: UITextField) {
        self.textField = textField
        super.init(frame: .zero)

        imageView.image = textFieldImage
        imageView.tintColor = .imagePrimary

        addSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Configurations

    /// 서브뷰 계층 구성
    private func addSubviews() {
        [imageView, textField, underlineView].forEach { addSubview($0) }
    }

    /// 전체 오토레이아웃 구성 진입점
    private func configureConstraints() {
        setImageViewConstraints()
        setTextfieldConstraints()
        setUnderlineViewConstraints()
    }

    /// 이미지 뷰 위치 설정
    private func setImageViewConstraints() {
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    /// 텍스트필드 위치 설정
    private func setTextfieldConstraints() {
        textField.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    /// 밑줄(underline) 뷰 위치 설정
    private func setUnderlineViewConstraints() {
        underlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
