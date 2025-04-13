//
//  FeedRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol FeedRouterProtocol {
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController)
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, from viewController: UIViewController)
    func navigate(to destination: TweetDestination, from viewController: UIViewController) 

}

