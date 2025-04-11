//
//  LoginViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class LoginViewModel {

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    private var email: String? {
        didSet {
            validateForm()
        }
    }
    private var password: String? {
        didSet {
            validateForm()
        }
    }

    var validate = false

    var onValidationChange: ((Bool, UIColor) -> Void)?
    var onSuccess: (() -> Void)?
    var onFail: ((String) -> Void)?


    func bindTextField(type: TextFieldType, text: String) {
        switch type {
        case .email:
            self.email = text
        case .password:
            self.password = text
        default:
            break
        }
    }
    private func validateForm() {
        validate = [
            email?.isEmpty == false,
            password?.isEmpty == false
        ].allSatisfy({$0})
        onValidationChange?(validate, validate ? UIColor.buttonEnabled : .buttonDisabled)
    }

    func login() {
        guard let email,
              let password else { return }

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
