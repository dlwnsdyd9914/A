//
//  LoginViewController 2.swift
//  A
//
//  Created by 이준용 on 4/16/25.
//


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

/// 로그인 화면 컨트롤러
/// - MVVM 아키텍처 기반
/// - 이메일/비밀번호 입력 → 유효성 검증 → 로그인 요청 → 성공 시 홈화면 전환
/// - SnapKit + Then으로 UI를 코드 기반으로 구성
final class LoginViewController: UIViewController {

    // MARK: - Dependencies

    /// 로그인 후 전환 및 회원가입 전환을 담당하는 라우터
    private let router: AuthRouterProtocol

    // MARK: - View Models

    /// 로그인 로직, 입력값 검증, 인증 처리 등을 담당하는 ViewModel
    private let viewModel: LoginViewModel

    // MARK: - UI Components

    /// 앱 로고 이미지
    private let logoImageView = UIImageView().then {
        $0.image = .mainLogo
    }

    /// 이메일 입력 필드
    private let emailTextField = CustomTextField(type: .email).then {
        $0.keyboardType = .emailAddress
    }

    /// 이메일 입력 필드 + 아이콘 포함한 컨테이너
    private lazy var emailInputContainerView = InputContainerView(
        textFieldImage: .emailImage,
        textField: emailTextField
    )

    /// 비밀번호 입력 필드
    private let passwordTextField = CustomTextField(type: .password).then {
        $0.isSecureTextEntry = true
    }

    /// 비밀번호 입력 필드 컨테이너
    private lazy var passwordInputContainerView = InputContainerView(
        textFieldImage: .passwordImage,
        textField: passwordTextField
    )

    /// 로그인 입력 필드들을 묶는 스택뷰
    private lazy var loginStackView = UIStackView(arrangedSubviews: [
        emailInputContainerView,
        passwordInputContainerView
    ]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    /// 로그인 실행 버튼 (입력값이 유효할 때 활성화됨)
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

    /// 회원가입 화면으로 전환하는 버튼
    private lazy var registerButton = UIButton(type: .custom).then {
        let attrbiutedTitle = $0.makeAttributedTitle(
            font: Fonts.authBottomButtonTitle,
            color: .textTitle,
            firstText: "계정이 없으신가요?",
            secondText: " 가입 하세요!"
        )
        $0.setAttributedTitle(attrbiutedTitle, for: .normal)
        $0.addTarget(self, action: #selector(handleRegisterButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// 라우터와 유즈케이스를 주입받아 ViewModel 구성
    init(router: AuthRouterProtocol, loginUseCase: LoginUseCaseProtocol) {
        self.router = router
        self.viewModel = LoginViewModel(loginUseCase: loginUseCase)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 미사용")
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

    /// 로그인 버튼 탭 시 → 로그인 요청 전달
    @objc private func handleLoginButtonTapped() {
        viewModel.login()
    }

    /// 회원가입 버튼 탭 시 → 회원가입 화면으로 전환
    @objc private func handleRegisterButtonTapped() {
        router.navigate(to: .register, from: self)
    }

    /// 텍스트 필드 변경 시 → ViewModel로 바인딩
    @objc private func handleTextFieldChange(textField: CustomTextField) {
        guard let text = textField.text,
              let type = textField.fieldType else { return }
        viewModel.bindTextField(type: type, text: text)
    }

    // MARK: - UI Configurations

    /// 전체 배경 및 초기 설정
    private func configureUI() {
        view.backgroundColor = .backGround
    }

    /// 뷰 계층 구성
    private func addSubviews() {
        [logoImageView, loginStackView, loginButton, registerButton].forEach {
            view.addSubview($0)
        }
    }

    /// 전체 컴포넌트 오토레이아웃 설정 진입점
    private func configureConstraints() {
        setLogoImageViewConstraints()
        setLoginStackViewConstraints()
        setLoginButtonConstraints()
        setRegisterButtonConstraints()
    }

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

    // MARK: - Alert 처리

    /// 로그인 실패 시 Alert 노출
    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    /// 로그인 성공 후 필드 초기화
    private func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    // MARK: - ViewModel 바인딩

    /// ViewModel에서 전달되는 상태를 바탕으로 UI 업데이트
    private func bindViewModel() {
        // 입력 유효성 변경 시 로그인 버튼 상태 변경
        viewModel.onValidationChange = { [weak self] isValid, buttonColor in
            guard let self else { return }
            DispatchQueue.main.async {
                self.loginButton.isEnabled = isValid
                self.loginButton.backgroundColor = buttonColor
            }
        }

        // 로그인 성공 시 → 텍스트 초기화 + 홈 화면 전환
        viewModel.onSuccess = { [weak self] in
            guard let self else { return }
            print("📲 LoginViewController - onSuccess 클로저 실행됨")
            DispatchQueue.main.async {
                self.clearTextFields()
                self.loginButton.backgroundColor = .buttonDisabled
                self.router.navigate(to: .login, from: self)
            }
        }

        // 로그인 실패 시 → 에러 Alert
        viewModel.onFail = { [weak self] errorMessage in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: errorMessage)
            }
        }
    }

    /// 텍스트필드 값 변경 → ViewModel에 바인딩
    private func bindTextField() {
        [emailTextField, passwordTextField].forEach {
            $0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        }
    }
}
