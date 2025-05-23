//
//  TweetRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

protocol TweetRouterProtocol {
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController)
    func presentActionSheet(viewModel: ActionSheetViewModel ,from viewController: UIViewController)
    func dismissAlert(_ alert: CustomAlertController, animated bool: Bool)
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController)

}
