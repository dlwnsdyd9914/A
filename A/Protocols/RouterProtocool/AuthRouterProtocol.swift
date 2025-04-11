//
//  AuthRouterProtocol.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

protocol AuthRouterProtocol {
    func navigate(to destination: AuthDestination, from viewController: UIViewController)
    func popNav(from viewController: UIViewController)
}
