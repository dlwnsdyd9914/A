//
//  UserViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

final class UserViewModel: UserViewModelProtocol {

    private var user: UserModelProtocol

    init(user: UserModelProtocol) {
        self.user = user
    }

    var username: String {
        return user.userName

    }

    var fullname: String {
        return user.fullName

    }

    var uid: String {
        return user.uid

    }

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)

    }

    var email: String {
        return user.email
    }

}
