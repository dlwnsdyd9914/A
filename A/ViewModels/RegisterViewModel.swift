//
//  RegisterViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

/// 회원가입 로직을 담당하는 ViewModel입니다.
/// 사용자 입력 값과 상태를 추적하며 유효성 검증을 수행하고,
/// 프로필 이미지 설정 및 회원가입 요청 로직을 포함합니다.
final class RegisterViewModel {

    // MARK: - Properties

    private let signUpUseCase: SignUpUseCaseProtocol

    /// 생성자 - 회원가입 UseCase를 주입
    init(signUpUseCase: SignUpUseCaseProtocol) {
        self.signUpUseCase = signUpUseCase
    }

    // 사용자 입력값 및 상태 저장
    private(set) var profileImage: UIImage? {
        didSet {
            onProfileImage?(profileImage)
            isProfileImageSelected = (profileImage?.size != .zero)
            validateForm()
        }
    }

    private var email: String? {
        didSet { validateForm() }
    }

    private var password: String? {
        didSet { validateForm() }
    }

    private var username: String? {
        didSet { validateForm() }
    }

    private var fullname: String? {
        didSet { validateForm() }
    }

    private var isProfileImageSelected = false
    private var isFormValid = false

    // MARK: - Output Closures

    /// 프로필 이미지 선택 시 전달
    var onProfileImage: ((UIImage?) -> Void)?

    /// 폼 유효성 상태 변경 시 전달 (버튼 활성화 + 색상)
    var onValidationChange: ((Bool, UIColor) -> Void)?

    /// 회원가입 성공 시 호출
    var onSuccess: (() -> Void)?

    /// 회원가입 실패 시 호출
    var onFail: ((String) -> Void)?

    // MARK: - Binding Functions

    /// 프로필 이미지 바인딩
    func bindProfileImage(profileImage: UIImage) {
        self.profileImage = profileImage
    }

    /// 텍스트 필드 입력값 바인딩
    func bindTextField(type: TextFieldType, text: String) {
        switch type {
        case .email:
            email = text
        case .password:
            password = text
        case .fullname:
            fullname = text
        case .username:
            username = text
        }
    }

    // MARK: - Validation

    /// 전체 폼 유효성 검사
    func validateForm() {
        isFormValid = [
            email?.isEmpty == false,
            password?.isEmpty == false,
            username?.isEmpty == false,
            fullname?.isEmpty == false,
            isProfileImageSelected
        ].allSatisfy { $0 }

        onValidationChange?(isFormValid, isFormValid ? .buttonEnabled : .buttonDisabled)
    }

    // MARK: - API Call

    /// 회원가입 요청
    func createUser() {
        guard let email, let password, let username, let fullname, let profileImage else {
            return
        }

        signUpUseCase.signUp(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                self.onSuccess?()
            case .failure(let error):
                self.onFail?(error.message)
            }
        }
    }
}
