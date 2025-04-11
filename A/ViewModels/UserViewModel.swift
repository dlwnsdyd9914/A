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

struct MockUserModel: UserModelProtocol {
    var bio: String

    var userFollowingCount: Int = 0

    var userFollowerCount: Int = 1

    var isCurrentUser: Bool = true

    var didFollow: Bool = false
    var email: String = "preview@example.com"
    var userName: String = "PreviewUser"
    var fullName: String = "Preview Full Name"
    var profileImageUrl: String = "https://via.placeholder.com/150"
    var uid: String = "previewUID"
}

