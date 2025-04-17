//
//  MainTabBarRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//


import UIKit

protocol MainTabBarRouterProtocol {
    func showLogin(from viewController: UIViewController)
    func logout(from viewController: UIViewController)

    func navigate(to destination: TweetDestination, from viewController: UIViewController)
    func popNav(from viewController: UIViewController)
}
