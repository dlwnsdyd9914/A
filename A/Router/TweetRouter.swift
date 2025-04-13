//
//  TweetRouter.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class TweetRouter: TweetRouterProtocol {

    



    private let tweetRepository: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol

    init(tweetRepository: TweetRepositoryProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, followUseCase: FollowUseCaseProtocol) {
        self.tweetRepository = tweetRepository
        self.tweetLikeUseCase = tweetLikeUseCase
        self.followUseCase = followUseCase
    }

    func navigateToTweetDetail( viewModel tweetViewModel: TweetViewModel, from viewController: UIViewController) {
        let tweetDetailVC = TweetController(viewModel: tweetViewModel, repository: tweetRepository, router: self, useCase: tweetLikeUseCase, followUseCase: followUseCase)
        viewController.navigationController?.pushViewController(tweetDetailVC, animated: true)
    }

    func presentActionSheet(viewModel: ActionSheetViewModel, from viewController: UIViewController) {
        let alert = CustomAlertController(viewModel: viewModel, router: self)
        alert.modalPresentationStyle = .overFullScreen
        viewController.present(alert, animated: true)
    }

    func dismissAlert(_ alert: CustomAlertController, animated bool: Bool) {
        weak var weakAlert = alert //주석 설명할포인트임 메모리해제관련
        UIView.animate(withDuration: 0.3, animations: {
            weakAlert?.blackView.alpha = 0
            weakAlert?.tableView.transform = CGAffineTransform(translationX: 0, y: weakAlert?.tableViewHeight ?? 0)
        }, completion: {_ in
            weakAlert?.dismiss(animated: bool)
        })
    }



}
