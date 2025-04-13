//
//  ExplorerRouter.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class ExplorerRouter: ExplorerRouterProtocol {


    private let mainTabRouter: MainTabBarRouterProtocol
    private let feedRouter: FeedRouterProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let tweetRepostiory: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol

    init(mainTabRouter: MainTabBarRouterProtocol, feedRouter: FeedRouterProtocol, tweetRepostiory: TweetRepositoryProtocol, followUseCase: FollowUseCaseProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol) {
        self.mainTabRouter = mainTabRouter
        self.feedRouter = feedRouter
        self.tweetRepostiory = tweetRepostiory
        self.followUseCase = followUseCase
        self.tweetLikeUseCase = tweetLikeUseCase
    }

    func navigateToUserProfile(user: UserModelProtocol, from viewController: UIViewController) {
        let userViewModel = UserViewModel(user: user)

        let profileController = ProfileController(router: mainTabRouter, userViewModel: userViewModel, repository: tweetRepostiory, useCase: followUseCase, feedRouter: feedRouter, tweetLikeUseCase: tweetLikeUseCase)
        viewController.navigationController?.pushViewController(profileController, animated: true)
    }

}

