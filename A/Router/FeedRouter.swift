//
//  FeedRouter.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class FeedRouter: FeedRouterProtocol {

    


    private let mainTabRouter: MainTabBarRouterProtocol
    private let tweetRouter: TweetRouterProtocol
    private let tweetRepository: TweetRepositoryProtocol
    private let uploadTweetRouter: UploadTweetRouterProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol


    init(mainTabRouter: MainTabBarRouterProtocol, tweetRepository: TweetRepositoryProtocol, tweetRouter: TweetRouterProtocol, uploadTweetRouter: UploadTweetRouterProtocol, followUseCase: FollowUseCaseProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol) {
        self.tweetRepository = tweetRepository
        self.mainTabRouter = mainTabRouter
        self.tweetRouter = tweetRouter
        self.uploadTweetRouter = uploadTweetRouter
        self.followUseCase = followUseCase
        self.tweetLikeUseCase = tweetLikeUseCase
    }

    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController) {

        let profileController = ProfileController(router: mainTabRouter, userViewModel: userViewModel, repository: tweetRepository, useCase: followUseCase, feedRouter: self, tweetLikeUseCase: tweetLikeUseCase)
        viewController.navigationController?.pushViewController(profileController, animated: true)
    }

    func navigateToTweetDetail( viewModel tweetViewModel: TweetViewModel, from viewController: UIViewController) {
        tweetRouter.navigateToTweetDetail(viewModel: tweetViewModel, from: viewController)
    }
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        uploadTweetRouter.navigate(to: destination, from: viewController)
    }



}
