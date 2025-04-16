//
//  UploadTweetRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol UploadTweetRouterProtocol {

    func navigate(to destination: TweetDestination, from viewController: UIViewController)

    func close(style presentationStyle: UploadTweetPresentationStyle, from viewController: UIViewController)
}
