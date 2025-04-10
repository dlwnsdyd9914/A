//
//  RegisterViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class RegisterViewModel {
    
    
    
    private let signUpUseCase: SignUpUseCaseProtocol

    init(signUpUserCase: SignUpUseCaseProtocol) {
        self.signUpUseCase = signUpUserCase
    }
    
    private(set) var profileImage: UIImage? {
        didSet {
            onProfileImage?(profileImage)
            isSelected = (profileImage?.size != .zero)
            validateForm()
        }
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
    
    private var username: String? {
        didSet {
            validateForm()
        }
    }
    
    private var fullname: String? {
        didSet {
            validateForm()
        }
    }
    
    private var isSelected = false
    private var validate = false
    
    
    var onProfileImage: ((UIImage?) -> Void)?
    var onValidationChange: ((Bool, UIColor) -> Void)?
    var onSuccess: (() -> Void)?
    var onFail: ((String) -> Void)?

    
    func bindProfileImage(profileImage: UIImage) {
        self.profileImage = profileImage
    }
    
    func bindTextField(type: TextFieldType, text: String) {
        switch type {
        case .email:
            self.email = text
        case .password:
            self.password = text
        case .fullname:
            self.fullname = text
        case .username:
            self.username = text
        }
    }
    
    func validateForm() {
        validate = [
            email?.isEmpty == false,
            password?.isEmpty == false,
            username?.isEmpty == false,
            fullname?.isEmpty == false,
            isSelected
        ].allSatisfy({$0})
        onValidationChange?(validate, validate ? UIColor.buttonEnabled : .buttonDisabled)
    }
    
    func createUser() {
        guard let email = email,
              let password = password,
              let username = username,
              let fullname = fullname,
              let profileImage = profileImage else { return }
        

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
