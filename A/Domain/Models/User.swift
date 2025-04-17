//
//  User.swift
//  A
//
//

import UIKit
import Firebase

/// 사용자 모델을 나타내는 클래스입니다.
/// - 역할: 파이어베이스에서 가져온 사용자 데이터를 기반으로 사용자 정보를 관리합니다.
/// - 주요 사용처: UserRepository, UserViewModel, TweetViewModel 등에서 유저 정보 접근 및 바인딩 시 사용됩니다.

final class User: UserModelProtocol {

    // MARK: - Properties

    /// 사용자의 팔로잉 수
    var userFollowingCount: Int = 0

    /// 사용자의 팔로워 수
    var userFollowerCount: Int = 0

    /// 이메일 주소
    var email: String

    /// 사용자 이름 (실명)
    var fullName: String

    /// 사용자 아이디 (@아이디)
    var userName: String

    /// Firebase 고유 UID
    var uid: String

    /// 프로필 이미지 URL (String 형태)
    var profileImageUrl: String

    /// 현재 로그인한 유저가 해당 유저를 팔로우하고 있는지 여부
    var didFollow: Bool = false

    /// 현재 로그인한 유저와 동일한지 여부
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }

    /// 유저 자기소개 또는 상태 메시지
    var bio: String

    // MARK: - Initializer

    /// Firebase에서 받아온 딕셔너리를 기반으로 User 인스턴스를 생성합니다.
    /// - Parameters:
    ///   - uid: 사용자 고유 UID
    ///   - dictionary: 사용자 정보 딕셔너리 (Firestore에서 받아온 데이터)
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.bio = dictionary["bio"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.userName = dictionary["userName"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }

    // MARK: - Methods

    /// 유저 정보를 외부에서 수정하는 함수
    /// - Parameters:
    ///   - fullName: 변경할 이름
    ///   - userName: 변경할 아이디
    ///   - bio: 변경할 소개
    ///   - profileImageUrl: 변경할 프로필 이미지 URL
    func applyEdit(fullName: String?, userName: String?, bio: String?, profileImageUrl: String?) {
        if let fullName = fullName { self.fullName = fullName }
        if let userName = userName { self.userName = userName }
        if let bio = bio { self.bio = bio }
        if let profileImageUrl = profileImageUrl { self.profileImageUrl = profileImageUrl }
    }
}
