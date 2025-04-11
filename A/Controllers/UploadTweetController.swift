//
//  UploadTweetController.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class UploadTweetController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

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
        $0.addTarget(self, action: #selector(handleUploadTweetButtonTapped), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let profileImageView = UIImageView().then { imageView in
        imageView.backgroundColor = .lightGray
    }

    private lazy var captionTextView = InputTextView().then {
        $0.backgroundColor = .brown
    }

    private let replyLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Reply"
        $0.textColor = .lightGray
    }

    // MARK: - Initializer

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        addSubViews()
        configureConstraints()
    }

    // MARK: - Selectors

    @objc private func handleCancleButtonTapped() {
        
    }

    @objc private func handleUploadTweetButtonTapped() {

    }

    // MARK: - UI Configurations

    private func configureUI() {
        self.view.backgroundColor = .white
    }

    private func configureNavigationBar() {



        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancleButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
    }

    private func addSubViews() {
        self.view.addSubview(profileImageView)
        self.view.addSubview(captionTextView)
        self.view.addSubview(replyLabel)
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
            $0.leading.equalTo(profileImageView.snp.trailing).inset(16)
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

    // MARK: - Bind ViewModels



}
