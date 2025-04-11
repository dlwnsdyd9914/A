//
//  RegisterViewController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import SwiftUI
import Then
import SnapKit

final class RegisterViewController: UIViewController {

    // MARK: - Properties

    private let router: AuthRouterProtocol

    // MARK: - View Models

    private var viewModel: RegisterViewModel

    // MARK: - UI Components

    private lazy var addProfileButton = UIButton(type: .custom).then {
        $0.setImage(UIImage.plusProfileImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleAddProfileButtonTapped), for: .touchUpInside)
    }

    private let emailTextField = CustomTextField(type: .email).then {
        $0.keyboardType = .emailAddress
    }

    private lazy var emailInputContainerView = InputContainerView(textFieldImage: .emailImage, textField: emailTextField)

    private let passwordTextField = CustomTextField(type: .password).then {
        $0.isSecureTextEntry = true
    }

    private lazy var passwordInputContainerView = InputContainerView(textFieldImage: .passwordImage, textField: passwordTextField)

    private let usernameTextField = CustomTextField(type: .username)

    private lazy var usernameInputContainerView = InputContainerView(textFieldImage: .nameFieldImage, textField: usernameTextField)

    private let fullnameTextField = CustomTextField(type: .fullname)

    private lazy var fullnameInputContainerView = InputContainerView(textFieldImage: .nameFieldImage, textField: fullnameTextField)

    private lazy var signStackView = UIStackView(arrangedSubviews: [emailInputContainerView, passwordInputContainerView, usernameInputContainerView, fullnameInputContainerView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    private lazy var signButton = UIButton(type: .custom).then {
        $0.setTitle("Sign In", for: .normal)
        $0.setTitleColor(.buttonTitleDisabled, for: .normal)
        $0.layer.cornerRadius = CornerRadius.medium
        $0.backgroundColor = .buttonDisabled
        $0.titleLabel?.font = Fonts.authButtonTitle
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(handleSignButtonTapped), for: .touchUpInside)
    }

    private lazy var loginButton = UIButton(type: .custom).then {
        let attrbiutedTitle = $0.makeAttributedTitle(font: Fonts.authBottomButtonTitle, color: .textTitle, firstText: "계정이 있으신가요?", secondText: " 로그인 하세요!")
        $0.setAttributedTitle(attrbiutedTitle, for: .normal)
        $0.addTarget(self, action: #selector(handleLoginButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    init(router: AuthRouterProtocol, signUpUseCase: SignUpUseCaseProtocol) {
        self.viewModel = RegisterViewModel(signUpUserCase: signUpUseCase)
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        addSubViews()
        configureConstraints()
        bindTextField()
        bindViewModel()
    }

    // MARK: - Selectors

    @objc private func handleAddProfileButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }

    @objc private func handleSignButtonTapped() {
        viewModel.createUser()
    }

    @objc private func handleLoginButtonTapped() {
        router.popNav(from: self)
    }

    @objc private func handleTextFieldChange(textField: CustomTextField) {
        guard let text = textField.text,
              let type = textField.fieldType else { return }
        viewModel.bindTextField(type: type, text: text)
    }

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    private func configureUI() {
        view.backgroundColor = .backGround
    }

    private func addSubViews() {
        [addProfileButton, signStackView, signButton, loginButton].forEach({view.addSubview($0)})
    }

    private func configureConstraints() {
        setAddProfileButtonConstraints()
        setSignStackViewConstraints()
        setSignButtonConstraints()
        setLoginButtonConstraints()
    }

    private func setAddProfileButtonConstraints() {
        addProfileButton.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(150)
        })
    }

    private func setSignStackViewConstraints() {
        signStackView.snp.makeConstraints({
            $0.top.equalTo(addProfileButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(200)
        })
    }

    private func setSignButtonConstraints() {
        signButton.snp.makeConstraints({
            $0.top.equalTo(signStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(50)
        })
    }

    private func setLoginButtonConstraints() {
        loginButton.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        })
    }

    // MARK: - Functions

    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onProfileImage = { [weak self] image in
            guard let self = self,
                  let profileImage = image else { return }
            DispatchQueue.main.async {
                self.addProfileButton.setImage(profileImage, for: .normal)
                self.addProfileButton.clipsToBounds = true
                self.addProfileButton.layer.cornerRadius = self.addProfileButton.frame.height / 2
            }
        }

        viewModel.onValidationChange = { [weak self] status, buttonColor in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.signButton.isEnabled = status
                self.signButton.backgroundColor = buttonColor
            }
        }

        viewModel.onSuccess = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.router.popNav(from: self)
            }
        }

        viewModel.onFail = { [weak self] errorMessage in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: errorMessage)
            }

        }
    }

    private func bindTextField() {
        [emailTextField, passwordTextField, usernameTextField, fullnameTextField].forEach({$0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)})
    }



}

extension RegisterViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let profileImage = info[.editedImage] as? UIImage else { return }

        viewModel.bindProfileImage(profileImage: profileImage)

        self.dismiss(animated: true)

    }
}

extension RegisterViewController: UINavigationControllerDelegate {

}

