//
//  LoginViewController.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import SwiftUI
import Then
import SnapKit

/// 앱의 로그인 화면 컨트롤러입니다.
/// UI 구성은 코드 기반으로 이루어졌으며, SnapKit + Then을 사용해 선언형으로 구현되어 있습니다.
final class LoginViewController: UIViewController {


    // MARK: - Properties

    private let router: AuthRouting

    // MARK: - View Models

    private let viewModel: LoginViewModel

    // MARK: - UI Components

    /// 앱 메인 로고 이미지 뷰
    private let logoImageView = UIImageView().then {
        $0.image = .mainLogo
    }

    private let emailTextField = CustomTextField(type: .email).then {
        $0.keyboardType = .emailAddress
    }

    private lazy var emailInputContainerView = InputContainerView(textFieldImage: .emailImage, textField: emailTextField)

    private let passwordTextField = CustomTextField(type: .password).then {
        $0.isSecureTextEntry = true
    }

    private lazy var passwordInputContainerView = InputContainerView(textFieldImage: .passwordImage, textField: passwordTextField)

    private lazy var loginStackView = UIStackView(arrangedSubviews: [emailInputContainerView, passwordInputContainerView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    private lazy var loginButton = UIButton(type: .custom).then {
        $0.setTitle("Login", for: .normal)
        $0.setTitleColor(.textPrimary, for: .normal)
        $0.titleLabel?.font = Fonts.authButtonTitle
        $0.backgroundColor = .buttonDisabled
        $0.isEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = CornerRadius.medium
        $0.addTarget(self, action: #selector(handleLoginButtonTapped), for: .touchUpInside)
    }

    private lazy var registerButton = UIButton(type: .custom).then {
        let attrbiutedTitle = $0.makeAttributedTitle(font: Fonts.authBottomButtonTitle, color: .textTitle, firstText: "계정이 없으신가요?", secondText: " 가입 하세요!")
        $0.setAttributedTitle(attrbiutedTitle, for: .normal)
        $0.addTarget(self, action: #selector(handleRegisterButtonTapped), for: .touchUpInside)
    }


    // MARK: - Initializer

    init(router: AuthRouting, loginUseCase: LoginUseCase) {
        self.router = router
        self.viewModel = LoginViewModel(loginUseCase: loginUseCase)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addSubviews()
        configureConstraints()
        bindTextField()
        bindViewModel()
    }


    // MARK: - Selectors

    @objc private func handleLoginButtonTapped() {
        viewModel.login()
    }

    @objc private func handleRegisterButtonTapped() {
        router.navigate(to: .register)
    }

    @objc private func handleTextFieldChange(textField: CustomTextField) {
        guard let text = textField.text,
              let type = textField.fieldType else { return }
        viewModel.bindTextField(type: type, text: text)
    }


    // MARK: - UI Configurations

    /// 배경 색상 등 초기 UI 설정
    private func configureUI() {
        self.view.backgroundColor = .backGround
    }

    /// 서브뷰 계층 구성
    private func addSubviews() {
        [logoImageView, loginStackView, loginButton, registerButton].forEach { self.view.addSubview($0) }
    }

    /// 오토레이아웃 전체 설정 진입점
    private func configureConstraints() {
        setLogoImageViewConstraints()
        setLoginStackViewConstraints()
        setLoginButtonConstraints()
        setRegisterButtonConstraints()
    }

    /// 로고 이미지뷰 오토레이아웃 설정
    private func setLogoImageViewConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(150)
        }
    }

    private func setLoginStackViewConstraints() {
        loginStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(100) // 각 인풋 50씩
        }
    }

    private func setLoginButtonConstraints() {
        loginButton.snp.makeConstraints({
            $0.top.equalTo(loginStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(50)
        })
    }

    private func setRegisterButtonConstraints() {
        registerButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(30)
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
        viewModel.onValidationChange = { [weak self] status, buttonColor in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loginButton.isEnabled = status
                self.loginButton.backgroundColor = .buttonEnabled
            }
        }

        viewModel.onSuccess = { [weak self] in
            guard let self else { return }
            self.router.navigate(to: .main)
        }

        viewModel.onFail = { [weak self] errorMessage in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: errorMessage)
            }

        }
    }

    private func bindTextField() {
        [emailTextField, passwordTextField].forEach({$0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)})
    }
}

//#Preview {
//    VCPreView {
//        let navController = UINavigationController()
//        let authCoordinator = AuthCoordinator(navigationController: navController, signUpUserCase: <#SignUpUseCase#>)
//        let loginVC = LoginViewController(router: authCoordinator)
//        navController.pushViewController(loginVC, animated: false)
//        return navController
//    }
//    .edgesIgnoringSafeArea(.all)
//}

