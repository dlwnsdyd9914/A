//
//  MainTabRouting.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol MainTabRouting: AnyObject {
    func showLogin()

    func logout()

    func navigate(to destination: TweetDestination)

    func popView()
}
