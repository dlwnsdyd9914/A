//
//  User.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit
import Firebase
final class User: UserModelProtocol {
    var userFollowingCount: Int = 0

    var userFollowerCount: Int = 0

    var email: String

    var fullName: String

    var userName: String

    var uid: String

    var profileImageUrl: String

    var didFollow: Bool = false

    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }

    var bio: String

    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid

        self.bio = dictionary["bio"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.userName = dictionary["userName"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }


}
