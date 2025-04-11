//
//  UploadTweetViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class UploadTweetViewModel {

    private let useCase: UploadTweetUseCaseProtocol

    init(tweetUploadUseCase: UploadTweetUseCaseProtocol) {
        self.useCase = tweetUploadUseCase
    }

    private(set) var caption: String? {
        didSet {
            guard let caption else { return }
            self.onCaptionText?(caption)
        }
    }

    var onTweetUploadSuccess: (() -> Void)?
    var onTweetUploadFail: ((String) -> Void)?
    var onCaptionText: ((String) -> Void)?

    func bindCaption(text: String) {
        self.caption = text
    }


    func uploadTweet() {
        guard let caption else { return }

        useCase.uploadTweet(caption: caption) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                self.onTweetUploadSuccess?()
            case .failure(let error):
                self.onTweetUploadFail?(error.message)
            }
        }

    }
}
