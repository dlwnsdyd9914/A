//
//  AuthRouting.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol AuthRouting: AnyObject {
    func navigate(to destination: AuthDestination)
    func popNav()
    
}
