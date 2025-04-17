//
//  ActionSheetViewModel.swift
//  A
//
//

import UIKit

/// 사용자에게 보여줄 액션 시트의 옵션들을 구성하고 처리하는 뷰모델입니다.
/// - 기능: 사용자 타입(본인 or 타인)에 따라 액션 옵션을 생성하고, 팔로우 상태를 토글 처리합니다.
final class ActionSheetViewModel {

    // MARK: - Properties

    /// 사용자 정보를 담고 있는 뷰모델
    private let userViewModel: UserViewModel

    /// 팔로우/언팔로우 비즈니스 로직을 수행할 유스케이스
    private let useCase: FollowUseCaseProtocol

    // MARK: - Output Closures

    /// 액션 처리 후 호출되는 클로저
    var onHandleAction: (() -> Void)?

    /// 팔로우 상태가 변경될 때 호출되는 클로저
    var onFollowToggled: (() -> Void)?

    // MARK: - Initializer

    init(userviewModel: UserViewModel, useCase: FollowUseCaseProtocol) {
        self.userViewModel = userviewModel
        self.useCase = useCase
    }

    // MARK: - Computed Properties

    /// 현재 사용자에 따라 액션 시트에 표시할 옵션 목록을 반환합니다.
    /// - 본인일 경우: [삭제, 신고]
    /// - 타인일 경우: [팔로우/언팔로우, 신고]
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

    /// 현재 유저 모델 반환
    var user: UserModelProtocol {
        return userViewModel.getUser()
    }

    // MARK: - Functions

    /// 유저 정보 가져오기 (내부에서 getUser 사용 가능하게 함)
    func getUser() -> UserModelProtocol {
        return userViewModel.getUser()
    }

    /// 팔로우/언팔로우 상태 토글 로직 수행
    func handleAction() {
        let shouldUnfollow = user.didFollow

        useCase.toggleFollow(didFollow: shouldUnfollow, uid: user.uid) { [weak self] in
            guard let self else { return }

            // 팔로우 상태 반영 (UI 갱신을 위해)
            self.userViewModel.didFollow = !shouldUnfollow
            self.onFollowToggled?()
        }
    }
}
