//
//  UploadTweetRouter.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class UploadTweetRouter: UploadTweetRouterProtocol {


    private let uploadTweetUseCase: UploadTweetUseCaseProtocol

    init(uploadTweetUseCase: UploadTweetUseCaseProtocol) {
        self.uploadTweetUseCase = uploadTweetUseCase
    }


    func dismiss(from viewController: UIViewController) {

    }

    func close(style presentationStyle: UploadTweetPresentationStyle, from viewController: UIViewController) {
        switch presentationStyle {
        case .modal:
            viewController.dismiss(animated: true)
        case .push:
            viewController.navigationController?.popViewController(animated: true)
        }
    }


    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        switch destination {
        case .uploadTweet(let userViewModel):
            let vc = UploadTweetController(router: self, userViewModel: userViewModel,
                                           configuration: .tweet, presentaionStyle: .modal, uploadTweetUseCase: uploadTweetUseCase)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            viewController.present(nav, animated: true)

        case .uploadReply(userViewModel: let userViewModel, tweet: let tweet):
            let vc = UploadTweetController(router: self, userViewModel: userViewModel,
                                           configuration: .reply(tweet), presentaionStyle: .push, uploadTweetUseCase: uploadTweetUseCase)
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

