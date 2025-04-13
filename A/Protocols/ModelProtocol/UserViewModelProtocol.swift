//
//  UserViewModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

protocol UserViewModelProtocol {
    var username: String { get }
    var fullname: String { get }
    var uid: String { get }
    var profileImageUrl: URL? { get }
    var email: String { get }
    var didFollow: Bool { get set}
    func updateFollowState(_ followed: Bool)
}
