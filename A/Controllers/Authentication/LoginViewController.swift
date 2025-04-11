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

    /// 화면 이동 처리를 담당하는 라우터
    private let router: AuthRouterProtocol

    // MARK: - View Models

    /// 로그인 관련 비즈니스 로직을 처리하는 뷰모델
    private let viewModel: LoginViewModel

    // MARK: - UI Components

    /// 앱 메인 로고 이미지 뷰
    private let logoImageView = UIImageView().then {
        $0.image = .mainLogo
    }

    /// 이메일 입력 텍스트 필드
    private let emailTextField = CustomTextField(type: .email).then {
        $0.keyboardType = .emailAddress
    }

    /// 이메일 입력 필드를 담은 뷰 (아이콘 포함)
    private lazy var emailInputContainerView = InputContainerView(textFieldImage: .emailImage, textField: emailTextField)

    /// 비밀번호 입력 텍스트 필드
    private let passwordTextField = CustomTextField(type: .password).then {
        $0.isSecureTextEntry = true
    }

    /// 비밀번호 입력 필드를 담은 뷰 (아이콘 포함)
    private lazy var passwordInputContainerView = InputContainerView(textFieldImage: .passwordImage, textField: passwordTextField)

    /// 이메일 + 비밀번호 필드 스택
    private lazy var loginStackView = UIStackView(arrangedSubviews: [emailInputContainerView, passwordInputContainerView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    /// 로그인 버튼
    private lazy var loginButton = UIButton(type: .custom).then {
        $0.setTitle("Login", for: .normal)
        $0.setTitleColor(.buttonTitleDisabled, for: .normal)
        $0.titleLabel?.font = Fonts.authButtonTitle
        $0.backgroundColor = .buttonDisabled
        $0.isEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = CornerRadius.medium
        $0.addTarget(self, action: #selector(handleLoginButtonTapped), for: .touchUpInside)
    }

    /// 회원가입 유도 텍스트 버튼
    private lazy var registerButton = UIButton(type: .custom).then {
        let attrbiutedTitle = $0.makeAttributedTitle(font: Fonts.authBottomButtonTitle, color: .textTitle, firstText: "계정이 없으신가요?", secondText: " 가입 하세요!")
        $0.setAttributedTitle(attrbiutedTitle, for: .normal)
        $0.addTarget(self, action: #selector(handleRegisterButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// 라우터와 로그인 유즈케이스를 주입받아 뷰모델을 구성
    init(router: AuthRouterProtocol, loginUseCase: LoginUseCaseProtocol) {
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

    // MARK: - Selectors (사용자 인터랙션 핸들러)

    /// 로그인 버튼 눌렀을 때
    @objc private func handleLoginButtonTapped() {
        viewModel.login()
    }

    /// 회원가입 버튼 눌렀을 때
    @objc private func handleRegisterButtonTapped() {
        router.navigate(to: .register, from: self)
    }

    /// 텍스트필드 값 변경될 때 뷰모델에 바인딩
    @objc private func handleTextFieldChange(textField: CustomTextField) {
        guard let text = textField.text,
              let type = textField.fieldType else { return }
        viewModel.bindTextField(type: type, text: text)
    }

    // MARK: - UI Configurations

    /// 배경색 및 초기 UI 세팅
    private func configureUI() {
        self.view.backgroundColor = .backGround
    }

    /// 뷰 계층 구성
    private func addSubviews() {
        [logoImageView, loginStackView, loginButton, registerButton].forEach { self.view.addSubview($0) }
    }

    /// 전체 컴포넌트 오토레이아웃 설정 진입점
    private func configureConstraints() {
        setLogoImageViewConstraints()
        setLoginStackViewConstraints()
        setLoginButtonConstraints()
        setRegisterButtonConstraints()
    }

    /// 로고 오토레이아웃 설정
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
            $0.height.equalTo(100)
        }
    }

    private func setLoginButtonConstraints() {
        loginButton.snp.makeConstraints {
            $0.top.equalTo(loginStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(50)
        }
    }

    private func setRegisterButtonConstraints() {
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(30)
        }
    }

    // MARK: - Functions

    /// 로그인 실패 시 사용자에게 에러 메시지 표시
    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    /// 텍스트필드 초기화
    private func clearTextFields() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }

    // MARK: - Bind ViewModels

    /// 뷰모델과 클로저 바인딩
    private func bindViewModel() {
        viewModel.onValidationChange = { [weak self] status, buttonColor in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loginButton.isEnabled = status
                self.loginButton.backgroundColor = buttonColor
            }
        }

        viewModel.onSuccess = { [weak self] in
            guard let self else { return }
            print("📲 LoginViewController - onSuccess 클로저 실행됨")
            DispatchQueue.main.async {
                self.clearTextFields()
                self.loginButton.backgroundColor = .buttonDisabled
                self.router.navigate(to: .login, from: self)
            }
        }

        viewModel.onFail = { [weak self] errorMessage in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: errorMessage)
            }
        }
    }

    /// 텍스트필드 이벤트 바인딩 (editingChanged)
    private func bindTextField() {
        [emailTextField, passwordTextField].forEach {
            $0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        }
    }
}
