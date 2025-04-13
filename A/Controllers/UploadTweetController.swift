//
//  UploadTweetController.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit
import Then
import SnapKit
import Kingfisher
import SwiftUI

final class UploadTweetController: UIViewController {

    // MARK: - Properties



    private let router: UploadTweetRouterProtocol

    private let uploadTweetUseCase: UploadTweetUseCaseProtocol


    // MARK: - View Models

    private let userViewModel: UserViewModel

    private let viewModel: UploadTweetViewModel

    // MARK: - UI Components

    private lazy var cancleButton = UIButton(type: .custom).then {
        $0.setTitle("Cancle", for: .normal)
        $0.setTitleColor(.backGround, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleCancleButtonTapped), for: .touchUpInside)
    }

    private lazy var uploadTweetButton = UIButton(type: .custom).then {
        $0.setTitle("Tweet", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = .backGround
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(handleUploadTweetButtonTapped), for: .touchUpInside)
    }

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    private lazy var captionTextView = InputTextView().then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    private let replyLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Reply"
        $0.textColor = .lightGray
    }

    // MARK: - Initializer

    init(router: UploadTweetRouterProtocol, userViewModel: UserViewModel, configuration: UploadTweetConfiguration, presentaionStyle: UploadTweetPresentationStyle, uploadTweetUseCase: UploadTweetUseCaseProtocol){
        self.uploadTweetUseCase = uploadTweetUseCase
        self.router = router
        self.userViewModel = userViewModel
        self.viewModel = UploadTweetViewModel(tweetUploadUseCase: uploadTweetUseCase, configuration: configuration, presentationStyle: presentaionStyle)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Life Cycles

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
        uploadTweetButton.layer.cornerRadius = uploadTweetButton.frame.height / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }

    // MARK: - Selectors

    @objc private func handleCancleButtonTapped() {
        router.close(style: viewModel.presentationStyle, from: self)
    }

    @objc private func handleUploadTweetButtonTapped() {
        viewModel.uploadTweet()
    }

    // MARK: - UI Configurations

    private func configureUI() {
        self.view.backgroundColor = .white
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBar.setDefaultAppearance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancleButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
    }

    private func addSubViews() {
        view.addSubview(profileImageView)
        view.addSubview(captionTextView)
        view.addSubview(replyLabel)
    }

    private func configureConstraints() {
        setUploadTweetButtonConstraints()
        setProfileImageViewConstraints()
        setCaptionTextViewConstraints()
        setReplyLabelConstraints()
    }

    private func setProfileImageViewConstraints() {
        profileImageView.snp.makeConstraints({
            $0.top.equalTo(replyLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        })
    }

    private func setCaptionTextViewConstraints() {
        captionTextView.snp.makeConstraints({
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        })
    }

    private func setUploadTweetButtonConstraints() {
        uploadTweetButton.snp.makeConstraints({
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        })
    }

    private func setReplyLabelConstraints() {
        replyLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().inset(16)
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
        viewModel.onCaptionText = { [weak self] caption in
            guard let self else { return }
            self.captionTextView.text = caption
        }

        viewModel.onTweetUploadFail = { [weak self] errorMessage in
            guard let self else { return }
            DispatchQueue.main.async {
                self.authErrorAlert(message: errorMessage)
            }
        }

        viewModel.onUploadResult = {[weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.router.close(style: self.viewModel.presentationStyle, from: self)
            }
        }

        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        replyLabel.text = viewModel.replyText
        uploadTweetButton.setTitle(viewModel.actionButtonTitle, for: .normal)
    }

    private func setProfileImageView(userViewModel: UserViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.profileImageView.kf.setImage(with: userViewModel.profileImageUrl)
        }
    }
}

extension UploadTweetController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bindCaption(text: textView.text)
    }
}

#Preview {

    let mockRouter = MockUploadTweetRouter()
    let mockUserViewModel = UserViewModel(user: MockUserModel(bio: "Test"))
    let mockUseCase = MockUploadTweetUseCase()
    let mockDiContainer = MockDiContainer()



    VCPreView {
        UINavigationController(rootViewController: UploadTweetController(router: mockRouter, userViewModel: mockUserViewModel, configuration: .tweet, presentaionStyle: .modal, uploadTweetUseCase: mockUseCase))
    }.edgesIgnoringSafeArea(.all)
}
