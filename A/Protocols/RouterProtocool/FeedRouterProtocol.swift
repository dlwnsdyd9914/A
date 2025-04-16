//
//  FeedRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol FeedRouterProtocol {
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController)
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController)
    func navigate(to destination: TweetDestination, from viewController: UIViewController)
    func naivgateToEditProfile(userViewModel: UserViewModel, editProfileHeaderViewModel: EditProfileHeaderViewModel, editProfileViewModel: EditProfileViewModel, from viewController: UIViewController, onProfileEdited: @escaping (UserModelProtocol) -> Void)
    func dismiss(from viewController: UIViewController)
    func popNav(from viewController: UIViewController)

}

