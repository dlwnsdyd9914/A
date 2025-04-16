//
//  EditProfileHeaderViewModel.swift
//  A
//
//

import UIKit

/// 프로필 수정 화면 상단에 표시되는 이미지 영역에 대한 상태를 관리하는 뷰모델입니다.
/// - 역할: 이미지 선택 후 뷰에 즉시 반영되도록 바인딩 처리
final class EditProfileHeaderViewModel {

    // MARK: - Properties

    /// 선택된 프로필 이미지
    var profileImage: UIImage? {
        didSet {
            onProfileImage?(profileImage)
        }
    }

    // MARK: - Output Bindings

    /// 프로필 이미지가 바뀌었을 때 뷰에 전달되는 클로저
    var onProfileImage: ((UIImage?) -> Void)?

    // MARK: - Functions

    /// 외부에서 이미지가 바인딩되었을 때 호출
    /// - Parameter image: 새롭게 선택된 이미지
    func bindProfileImage(image: UIImage) {
        self.profileImage = image
    }
}
