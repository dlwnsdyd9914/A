//
//  LoginViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

/// 로그인 화면에서 사용되는 ViewModel입니다.
/// 이메일/비밀번호 유효성 검증 및 로그인 요청을 처리하며,
/// ViewController와의 클로저 바인딩을 통해 상태 변화를 전달합니다.
final class LoginViewModel {

    // MARK: - Properties

    private let loginUseCase: LoginUseCaseProtocol

    /// 생성자: 로그인 UseCase 주입
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    /// 사용자 입력 값
    private var email: String? {
        didSet { validateForm() }
    }

    private var password: String? {
        didSet { validateForm() }
    }

    /// 현재 입력된 값이 유효한지 여부
    private var isFormValid: Bool = false

    // MARK: - Output Closures

    /// 폼 유효성 변경 시 (버튼 활성화 여부 + 색상)
    var onValidationChange: ((Bool, UIColor) -> Void)?

    /// 로그인 성공 시 호출
    var onSuccess: (() -> Void)?

    /// 로그인 실패 시 호출
    var onFail: ((String) -> Void)?

    // MARK: - Binding

    /// 텍스트 필드 변경값 바인딩
    func bindTextField(type: TextFieldType, text: String) {
        switch type {
        case .email:
            email = text
        case .password:
            password = text
        default:
            break
        }
    }

    // MARK: - Validation

    /// 입력값 유효성 검사
    private func validateForm() {
        isFormValid = [
            email?.isEmpty == false,
            password?.isEmpty == false
        ].allSatisfy { $0 }

        onValidationChange?(isFormValid, isFormValid ? .buttonEnabled : .buttonDisabled)
    }

    // MARK: - API Call

    /// 로그인 요청
    func login() {
        guard let email, let password else { return }

        loginUseCase.login(email: email, password: password) { [weak self] result in
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
