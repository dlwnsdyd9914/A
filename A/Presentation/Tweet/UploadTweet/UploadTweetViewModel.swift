//
//  UploadTweetViewModel.swift
//  A
//
//

import UIKit

/// 트윗 작성 및 리플 작성 시 사용하는 UploadTweet 화면의 ViewModel
/// - 기능: 트윗 or 리플 업로드 처리, UI 상태 바인딩, 버튼 타이틀/레이블 등 상태 제어
final class UploadTweetViewModel {

    // MARK: - Dependencies

    private let useCase: UploadTweetUseCaseProtocol

    // MARK: - Configuration

    /// 현재 업로드 타입 (트윗 or 리플)
    var uploadTweetConfiguration = UploadTweetConfiguration.tweet {
        didSet {
            onUploadTweetConfiguration?(uploadTweetConfiguration)
            configureationUploadTweet()
        }
    }

    /// 트윗 작성화면의 표현 방식 (present or push 등)
    var presentationStyle: UploadTweetPresentationStyle

    // MARK: - Initializer

    init(tweetUploadUseCase: UploadTweetUseCaseProtocol, configuration: UploadTweetConfiguration = .tweet, presentationStyle: UploadTweetPresentationStyle) {
        self.useCase = tweetUploadUseCase
        self.uploadTweetConfiguration = configuration
        self.presentationStyle = presentationStyle
        configureationUploadTweet()
    }

    // MARK: - Data Properties (바인딩용)

    /// 입력된 캡션 텍스트 (트윗 or 리플)
    private(set) var caption: String? {
        didSet {
            guard let caption else { return }
            self.onCaptionText?(caption)
        }
    }

    /// 업로드 버튼에 표시될 텍스트 ("Tweet" or "Reply")
    private(set) var actionButtonTitle: String = "" {
        didSet {
            onActionButtonTitleChanged?(actionButtonTitle)
        }
    }

    /// 리플 라벨 노출 여부
    var shouldShowReplyLabel = false {
        didSet {
            onReplyLabelVisibilityChanged?(shouldShowReplyLabel)
        }
    }

    /// 리플일 경우 상단 안내 텍스트 ("Replying to @username")
    var replyText: String? {
        didSet {
            guard let replyText else { return }
            onReplyText?(replyText)
        }
    }

    // MARK: - Binding Events

    var onUploadResult: (() -> Void)?
    var onTweetUploadFail: ((String) -> Void)?
    var onCaptionText: ((String) -> Void)?
    var onUploadTweetConfiguration: ((UploadTweetConfiguration) -> Void)?
    var onActionButtonTitleChanged: ((String) -> Void)?
    var onReplyLabelVisibilityChanged: ((Bool) -> Void)?
    var onReplyText: ((String) -> Void)?

    // MARK: - Bind Input

    /// 캡션 텍스트 바인딩 (텍스트필드 or 텍스트뷰에서 입력받아 처리)
    func bindCaption(text: String) {
        self.caption = text
    }

    // MARK: - Upload Tweet

    /// 현재 설정에 맞춰 트윗 or 리플 업로드 요청
    func uploadTweet() {
        guard let caption else { return }

        switch uploadTweetConfiguration {
        case .tweet:
            useCase.uploadNewTweet(caption: caption) { [weak self] result in
                guard let self else { return }
                self.onUploadResult?()
            }

        case .reply(let tweet):
            useCase.uploadReply(caption: caption, to: tweet) { [weak self] result in
                guard let self else { return }
                self.onUploadResult?()
            }
        }
    }

    // MARK: - Configure 상태값에 따라 UI 제어

    /// 업로드 타입에 따라 버튼 타이틀, 리플 라벨 여부 등 UI 설정 적용
    func configureationUploadTweet() {
        switch uploadTweetConfiguration {
        case .tweet:
            self.actionButtonTitle = "Tweet"
            self.shouldShowReplyLabel = false

        case .reply(let tweet):
            self.actionButtonTitle = "Reply"
            self.shouldShowReplyLabel = true
            self.replyText = "Replying to @\(tweet.user.userName)"
        }
    }
}
