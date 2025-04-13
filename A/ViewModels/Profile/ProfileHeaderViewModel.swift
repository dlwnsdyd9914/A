//
//  ProfileHeaderViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class ProfileHeaderViewModel: ProfileHeaderViewModelProtocol {

    private var user: UserModelProtocol

    private let useCase: FollowUseCaseProtocol

    init(user: UserModelProtocol, useCase: FollowUseCaseProtocol) {
        self.user = user
        self.useCase = useCase
    }

    var followerString: NSAttributedString {
        return followAttributedText(value: user.userFollowerCount, text: "follwer")
    }

    var followingString: NSAttributedString {
        return followAttributedText(value: user.userFollowingCount, text: "following")
    }

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }

    var infoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        } else {
            return didFollow ? "Following" : "Follow"
        }
    }

    var fullname: String {
        return user.fullName
    }

    var username: String {
        return user.userName
    }

    var uid: String {
        return user.uid
    }

    var didFollow: Bool {
        get {
            return user.didFollow
        }
        set {
            user.didFollow = newValue
        }
    }

    func getUser() -> UserModelProtocol {
        return user
    }

    var onFollowToggled: (() -> Void)?
    var onFollowStatusCheck: ((String) -> Void)?
    var onFollowLabelCount: (() -> Void)?
    var onEditProfileTapped: (() -> Void)?
    


    func followAttributedText(value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedText
    }

    func followToggled() {
        if user.isCurrentUser {
            print("프로필 편집")
            onEditProfileTapped?()
            return
        }
        useCase.toggleFollow(didFollow: didFollow, uid: uid) { [weak self] in
            guard let self else { return }
            self.user.didFollow.toggle()
            self.onFollowToggled?()
        }
    }

    func checkingFollow() {
        useCase.checkFollowStatus(uid: uid) {[weak self] followStatus in
            guard let self else { return }
            self.user.didFollow = followStatus
            self.onFollowStatusCheck?(followStatus ? "Following" : "Follow")
        }
    }

    func getFollowCount() {
        useCase.getFollowCounts(uid: uid) {[weak self] following, follower in
            guard let self else { return }

            self.user.userFollowingCount = following
            self.user.userFollowerCount = follower
            self.onFollowLabelCount?()
        }
    }

    func handleEditFollowButtonTapped() {
        followToggled()
    }




}
