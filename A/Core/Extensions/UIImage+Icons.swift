//
//  UIImage+Icons.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

extension UIImage {

    // MARK: - TabBar Icons
    static let feedImage = UIImage(named: "home_unselected")!
    static let searchImage = UIImage(named: "search_unselected")!
    static let notificationImage = UIImage(named: "like_unselected")!

    // MARK: - Auth / Form
    static let emailImage = UIImage(named: "mail")!
    static let passwordImage = UIImage(named: "ic_lock_outline_white_2x")!
    static let nameFieldImage = UIImage(named: "ic_person_outline_white_2x")!

    // MARK: - Common
    static let mainLogo = UIImage(named: "TwitterLogo")!
    static let newTweetImage = UIImage(named: "new_tweet")!
    static let plusProfileImage = UIImage(named: "plus_photo")!

    // MARK: - Tweet Actions
    static let commentImage = #imageLiteral(resourceName: "comment")
    static let retweetImage = #imageLiteral(resourceName: "retweet")
    static let shareImage = UIImage(named: "share")!
    static let likeImage = UIImage(named: "like")!
    static let backImage = #imageLiteral(resourceName: "baseline_arrow_back_white_24dp")

}
