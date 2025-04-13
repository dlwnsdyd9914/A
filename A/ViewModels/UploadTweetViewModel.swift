//
//  UploadTweetViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class UploadTweetViewModel {

    private let useCase: UploadTweetUseCaseProtocol

    var uploadTweetConfiguration = UploadTweetConfiguration.tweet {
        didSet {
            onUploadTweetConfiguration?(uploadTweetConfiguration)
            configureationUploadTweet()
        }
    }

    var presentationStyle:  UploadTweetPresentationStyle

    init(tweetUploadUseCase: UploadTweetUseCaseProtocol, configuration: UploadTweetConfiguration = .tweet, presentationStyle: UploadTweetPresentationStyle) {
        self.useCase = tweetUploadUseCase
        self.uploadTweetConfiguration = configuration
        self.presentationStyle = presentationStyle
        configureationUploadTweet()
    }

    private(set) var caption: String? {
        didSet {
            guard let caption else { return }
            self.onCaptionText?(caption)
        }
    }

    private(set) var actionButtonTitle: String = "" {
        didSet {
            onActionButtonTitleChanged?(actionButtonTitle)
        }
    }
    var shouldShowReplyLabel = false {
        didSet {
            onReplyLabelVisibilityChanged?(shouldShowReplyLabel)
        }
    }

    var replyText: String? {
        didSet {
            guard let replyText else { return }
            onReplyText?(replyText)
        }
    }




    var onUploadResult: (() -> Void)?
    var onTweetUploadFail: ((String) -> Void)?
    var onCaptionText: ((String) -> Void)?
    var onUploadTweetConfiguration: ((UploadTweetConfiguration) -> Void)?
    var onActionButtonTitleChanged: ((String) -> Void)?
    var onReplyLabelVisibilityChanged: ((Bool) -> Void)?
    var onReplyText: ((String) -> Void)?



    func bindCaption(text: String) {
        self.caption = text
    }


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

