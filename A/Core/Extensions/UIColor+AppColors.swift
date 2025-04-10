//
//  UIColor+AppColors.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    static let backGround = UIColor.rgb(red: 29, green: 161, blue: 242)

    // 텍스트 필드 내 텍스트
    static let textPrimary = UIColor.white

    // 플레이스홀더용 (보통 살짝 투명도 주는 경우 많음)
    static let textPlaceholder = UIColor.white.withAlphaComponent(0.6)

    // 타이틀, 라벨에 들어가는 굵은 텍스트
    static let textTitle = UIColor.white

    /// 텍스트 필드 등 인풋 바텀 구분선용 컬러
    static let underLine = UIColor.white

    static let imagePrimary = UIColor.white


    // 버튼 활성화 상태일 때 (enabled)
    static let buttonEnabled = UIColor.white

    // 버튼 비활성화 상태일 때 (disabled)
    static let buttonDisabled = UIColor.white.withAlphaComponent(0.3)

    // 버튼 활성화 상태 텍스트 컬러
    static let buttonTitleEnabled = UIColor.systemBlue

    // 버튼 비활성화 상태 텍스트 컬러
    static let buttonTitleDisabled = UIColor.systemBlue.withAlphaComponent(0.4)


}
