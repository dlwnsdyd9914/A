//
//  UserModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

protocol UserModelProtocol {
    var email: String { get }
    var fullName: String { get set}
    var userName: String { get set }
    var uid: String { get }
    var profileImageUrl: String { get set }
    var didFollow: Bool { get set }
    var isCurrentUser: Bool { get }
    var userFollowingCount: Int { get set }
    var userFollowerCount: Int { get set }
    var bio: String { get set }
    func applyEdit(fullName: String?, userName: String?, bio: String?, profileImageUrl: String?)
}
