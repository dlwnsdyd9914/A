//
//  ActionSheetViewModel.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class ActionSheetViewModel {
    private let userViewModel: UserViewModel
    private let useCase: FollowUseCaseProtocol

    init(userviewModel: UserViewModel, useCase: FollowUseCaseProtocol) {
        self.userViewModel = userviewModel
        self.useCase = useCase
    }


    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        let user = userViewModel.getUser()

        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOptions: ActionSheetOptions = user.didFollow ? .unfollow(getUser()) : .follow(user)
            results.append(followOptions)
        }

        results.append(.report)
        return results
    }

    var user: UserModelProtocol {
        return userViewModel.getUser()
    }


    var onHandleAction: (() -> Void)?
    var onFollowToggled: (() -> Void)?




    func getUser() -> UserModelProtocol {
        return userViewModel.getUser()
    }

    func handleAction() {
        let shouldUnfollow = user.didFollow

        useCase.toggleFollow(didFollow: shouldUnfollow, uid: user.uid) { [weak self] in
            guard let self else { return }

            // 명시적으로 값 대입
            self.userViewModel.didFollow = !shouldUnfollow
            self.onFollowToggled?()
        }
    }

}
