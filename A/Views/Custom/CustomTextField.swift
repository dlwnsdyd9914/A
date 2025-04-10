//
//  CustomTextField.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

/// 플레이스홀더, 폰트, 텍스트 컬러 등 기본 스타일이 적용된 커스텀 텍스트 필드입니다.
/// 로그인/회원가입 등의 입력폼에서 재사용됩니다.
final class CustomTextField: UITextField {


    var fieldType: TextFieldType?

    // MARK: - Initializer

    /// 플레이스홀더 텍스트를 받아 텍스트 필드를 초기화합니다.
    /// 스타일은 내부 `setup`에서 일괄 적용됩니다.
    init(type: TextFieldType) {
        self.fieldType = type
        super.init(frame: .zero)

        setup(placeholder: type.description)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    /// 기본 스타일 적용
    /// - 플레이스홀더 스타일은 `AttributedTextApplicable` 프로토콜에서 제공되는 메서드로 생성
    /// - 폰트 및 텍스트 컬러는 전역 스타일 가이드(`Fonts`, `UIColor+AppColor`)를 따름
    private func setup(placeholder: String) {
        self.attributedPlaceholder = makeAttributedText(
            font: .boldSystemFont(ofSize: 16),
            color: .white,
            text: placeholder
        )

        self.font = Fonts.textField
        self.textColor = .textPrimary
        self.autocapitalizationType = .none
    }
}
