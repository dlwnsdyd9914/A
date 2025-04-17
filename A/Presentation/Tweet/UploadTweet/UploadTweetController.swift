//
//  UploadTweetController.swift
//  A
//
//

import UIKit
import Then
import SnapKit
import Kingfisher
import ActiveLabel
import SwiftUI

/// 트윗 업로드 화면을 담당하는 ViewController
/// - 트윗 작성 또는 리플 작성에 따라 레이아웃 및 버튼 액션 분기
/// - MVVM 아키텍처 기반으로 ViewModel과 의존성 분리
/// - Router를 통한 화면 전환 관리
final class UploadTweetController: UIViewController {

    // MARK: - Dependencies

    /// 화면 전환 및 종료 처리를 위한 라우터
    private let router: UploadTweetRouterProtocol

    /// 트윗 업로드 비즈니스 로직 처리 유즈케이스
    private let uploadTweetUseCase: UploadTweetUseCaseProtocol

    // MARK: - View Models

    /// 현재 로그인된 유저 상태 관리 뷰모델
    private let userViewModel: UserViewModel

    /// 트윗 작성 및 업로드 상태 관리 뷰모델
    private let viewModel: UploadTweetViewModel

    // MARK: - UI Components

    /// 업로드 취소 버튼 (좌측 상단)
    private lazy var cancleButton = UIButton(type: .custom).then {
        $0.setTitle("Cancle", for: .normal)
        $0.setTitleColor(.backGround, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleCancleButtonTapped), for: .touchUpInside)
    }

    /// 트윗 업로드 실행 버튼 (우측 상단)
    private lazy var uploadTweetButton = UIButton(type: .custom).then {
        $0.setTitle("Tweet", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = .backGround
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleUploadTweetButtonTapped), for: .touchUpInside)
    }

    /// 유저 프로필 이미지
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    /// 트윗 본문 입력 텍스트 뷰
    private lazy var captionTextView = InputTextView().then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    /// 답글 대상 유저를 보여주는 라벨 (@mention), 리플 작성 시에만 노출
    private let replyLabel = ActiveLabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Reply"
        $0.textColor = .lightGray
        $0.mentionColor = .backGround
    }

    // MARK: - Initializer

    /// DI 기반 생성자: ViewModel 생성 및 초기화 시점에 의존성 주입
    init(router: UploadTweetRouterProtocol, userViewModel: UserViewModel, configuration: UploadTweetConfiguration, presentaionStyle: UploadTweetPresentationStyle, uploadTweetUseCase: UploadTweetUseCaseProtocol){
        self.uploadTweetUseCase = uploadTweetUseCase
        self.router = router
        self.userViewModel = userViewModel
        self.viewModel = UploadTweetViewModel(tweetUploadUseCase: uploadTweetUseCase, configuration: configuration, presentationStyle: presentaionStyle)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard 사용하지 않음")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        addSubViews()
        configureConstraints()
        setProfileImageView(userViewModel: userViewModel)
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 동그란 버튼 및 프로필 이미지 설정
        uploadTweetButton.layer.cornerRadius = uploadTweetButton.frame.height / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }

    // MARK: - Actions

    /// 취소 버튼 클릭 시, Router를 통해 화면 종료
    @objc private func handleCancleButtonTapped() {
        router.close(style: viewModel.presentationStyle, from: self)
    }

    /// 트윗 업로드 버튼 클릭 시 ViewModel에 위임
    @objc private func handleUploadTweetButtonTapped() {
        viewModel.uploadTweet()
    }

    // MARK: - UI Setup

    /// 기본 배경 설정
    private func configureUI() {
        self.view.backgroundColor = .white
    }

    /// 네비게이션바 커스텀 버튼 설정
    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancleButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
    }

    /// 하위 뷰 추가
    private func addSubViews() {
        view.addSubview(profileImageView)
        view.addSubview(captionTextView)
        view.addSubview(replyLabel)
    }

    /// 오토레이아웃 설정 (SnapKit 사용)
    private func configureConstraints() {
        setUploadTweetButtonConstraints()
        setProfileImageViewConstraints()
        setCaptionTextViewConstraints()
        setReplyLabelConstraints()
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(replyLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }
    }

    private func setCaptionTextViewConstraints() {
        captionTextView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    private func setUploadTweetButtonConstraints() {
        uploadTweetButton.snp.makeConstraints {
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        }
    }

    private func setReplyLabelConstraints() {
        replyLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().inset(16)
        }
    }

    // MARK: - Bind ViewModels

    /// ViewModel의 상태 변화에 따른 UI 반영
    private func bindViewModel() {
        viewModel.onCaptionText = { [weak self] caption in
            self?.captionTextView.text = caption
        }

        viewModel.onTweetUploadFail = { [weak self] errorMessage in
            self?.authErrorAlert(message: errorMessage)
        }

        viewModel.onUploadResult = { [weak self] in
            self?.router.close(style: self?.viewModel.presentationStyle ?? .modal, from: self!)
        }

        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        replyLabel.text = viewModel.replyText
        uploadTweetButton.setTitle(viewModel.actionButtonTitle, for: .normal)
    }

    /// 유저 프로필 이미지 셋업 (비동기 처리)
    private func setProfileImageView(userViewModel: UserViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.profileImageView.kf.setImage(with: userViewModel.profileImageUrl)
        }
    }

    /// 업로드 실패 시 알럿 노출
    private func authErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension UploadTweetController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bindCaption(text: textView.text)
    }
}

// MARK: - SwiftUI 미리보기 (Xcode Preview)

#Preview {
    let mockRouter = MockUploadTweetRouter()
    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "Test"), followUseCase: MockFollowUseCase())
    let mockUseCase = MockUploadTweetUseCase()

    VCPreView {
        UINavigationController(
            rootViewController: UploadTweetController(
                router: mockRouter,
                userViewModel: mockUserViewModel,
                configuration: .tweet,
                presentaionStyle: .modal,
                uploadTweetUseCase: mockUseCase
            )
        )
    }.edgesIgnoringSafeArea(.all)
}
