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

/// 회원가입을 담당하는 화면 컨트롤러입니다.
/// SnapKit과 Then을 이용해 코드 기반 UI로 구성되어 있으며, MVVM 패턴 기반으로 ViewModel과 바인딩됩니다.
final class RegisterViewController: UIViewController {

    // MARK: - Properties

    /// 화면 전환 및 네비게이션 처리를 담당하는 라우터
    private let router: AuthRouterProtocol

    // MARK: - View Models

    /// 회원가입 관련 로직과 유효성 검증, 상태 관리를 담당하는 뷰모델
    private var viewModel: RegisterViewModel

    // MARK: - UI Components

    /// 프로필 이미지 추가 버튼 (기본 이미지는 플러스 아이콘)
    private lazy var addProfileButton = UIButton(type: .custom).then {
        $0.setImage(UIImage.plusProfileImage.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleAddProfileButtonTapped), for: .touchUpInside)
    }

    /// 이메일 입력 필드
    private let emailTextField = CustomTextField(type: .email).then {
        $0.keyboardType = .emailAddress
    }

    /// 이메일 입력 필드 컨테이너 (아이콘 포함)
    private lazy var emailInputContainerView = InputContainerView(textFieldImage: .emailImage, textField: emailTextField)

    /// 비밀번호 입력 필드
    private let passwordTextField = CustomTextField(type: .password).then {
        $0.isSecureTextEntry = true
    }

    /// 비밀번호 입력 필드 컨테이너
    private lazy var passwordInputContainerView = InputContainerView(textFieldImage: .passwordImage, textField: passwordTextField)

    /// 사용자 이름 입력 필드
    private let usernameTextField = CustomTextField(type: .username)

    /// 사용자 이름 입력 필드 컨테이너
    private lazy var usernameInputContainerView = InputContainerView(textFieldImage: .nameFieldImage, textField: usernameTextField)

    /// 전체 이름 입력 필드
    private let fullnameTextField = CustomTextField(type: .fullname)

    /// 전체 이름 입력 필드 컨테이너
    private lazy var fullnameInputContainerView = InputContainerView(textFieldImage: .nameFieldImage, textField: fullnameTextField)

    /// 입력 필드 스택뷰 (이메일, 비밀번호, 유저네임, 풀네임 포함)
    private lazy var signStackView = UIStackView(arrangedSubviews: [emailInputContainerView, passwordInputContainerView, usernameInputContainerView, fullnameInputContainerView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    /// 회원가입 버튼
    private lazy var signButton = UIButton(type: .custom).then {
        $0.setTitle("Sign In", for: .normal)
        $0.setTitleColor(.buttonTitleDisabled, for: .normal)
        $0.layer.cornerRadius = CornerRadius.medium
        $0.backgroundColor = .buttonDisabled
        $0.titleLabel?.font = Fonts.authButtonTitle
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(handleSignButtonTapped), for: .touchUpInside)
    }

    /// 로그인 화면으로 돌아가는 버튼
    private lazy var loginButton = UIButton(type: .custom).then {
        let attributedTitle = $0.makeAttributedTitle(font: Fonts.authBottomButtonTitle, color: .textTitle, firstText: "계정이 있으신가요?", secondText: " 로그인 하세요!")
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.addTarget(self, action: #selector(handleLoginButtonTapped), for: .touchUpInside)
    }

    // MARK: - Initializer

    /// 라우터와 회원가입 유즈케이스를 주입받아 뷰모델 생성
    init(router: AuthRouterProtocol, signUpUseCase: SignUpUseCaseProtocol) {
        self.viewModel = RegisterViewModel(signUpUseCase: signUpUseCase)
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

    /// 프로필 이미지 버튼 탭 - 이미지 피커 호출
    @objc private func handleAddProfileButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }

    /// 회원가입 버튼 탭
    @objc private func handleSignButtonTapped() {
        viewModel.createUser()
    }

    /// 로그인 버튼 탭 - 네비게이션 pop
    @objc private func handleLoginButtonTapped() {
        router.popNav(from: self)
    }

    /// 텍스트필드 변경 시 뷰모델에 바인딩
    @objc private func handleTextFieldChange(textField: CustomTextField) {
        guard let text = textField.text,
              let type = textField.fieldType else { return }
        viewModel.bindTextField(type: type, text: text)
    }

    // MARK: - UI Configurations

    /// 네비게이션 바 숨기기
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    /// 배경색 설정
    private func configureUI() {
        view.backgroundColor = .backGround
    }

    /// 서브뷰 추가
    private func addSubViews() {
        [addProfileButton, signStackView, signButton, loginButton].forEach({ view.addSubview($0) })
    }

    /// 전체 오토레이아웃 설정 진입점
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

    /// 회원가입 실패 시 알림
    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    // MARK: - Bind ViewModels

    /// 뷰모델과 클로저 바인딩
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

    /// 텍스트필드 바인딩 (입력값 변경 시 뷰모델에 반영)
    private func bindTextField() {
        [emailTextField, passwordTextField, usernameTextField, fullnameTextField].forEach {
            $0.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        }
    }
}

// MARK: - 이미지 피커 처리
extension RegisterViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        viewModel.bindProfileImage(profileImage: profileImage)
        self.dismiss(animated: true)
    }
}

// MARK: - 네비게이션 컨트롤러 델리게이트
extension RegisterViewController: UINavigationControllerDelegate { }
