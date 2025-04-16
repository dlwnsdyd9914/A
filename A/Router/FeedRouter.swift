//
//  FeedRouter.swift
//  A
//
//

import UIKit

/// 피드 화면에서 발생하는 모든 라우팅 처리를 담당하는 클래스입니다.
///
/// - 역할:
///     - 트윗 디테일, 유저 프로필, 트윗 업로드, 프로필 수정 등 다양한 화면으로의 이동 처리
///
/// - 주요 사용처:
///     - FeedController 내에서 UI 이벤트(탭, 버튼 등) 발생 시 화면 전환 요청
///
/// - 설계 이유:
///     - 라우팅 책임을 FeedController에서 분리하여 SRP(단일 책임 원칙) 유지
///     - TweetRouter/UploadTweetRouter 등 하위 라우터를 주입받아 유연한 화면 전환 구성 가능
final class FeedRouter: FeedRouterProtocol {

    // MARK: - Dependencies

    private let mainTabRouter: MainTabBarRouterProtocol
    private var tweetRouter: TweetRouterProtocol?
    private let tweetRepository: TweetRepositoryProtocol
    private let uploadTweetRouter: UploadTweetRouterProtocol
    private let profileUseCase: ProfileUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let userRepository: UserRepositoryProtocol
    private let editUseCase: EditUseCaseProtocol

    // MARK: - Initializer

    init(mainTabRouter: MainTabBarRouterProtocol, tweetRepository: TweetRepositoryProtocol, uploadTweetRouter: UploadTweetRouterProtocol, followUseCase: FollowUseCaseProtocol, tweetLikeUseCase: TweetLikeUseCaseProtocol, profileUseCase: ProfileUseCaseProtocol, userRepository: UserRepositoryProtocol, editUseCase: EditUseCaseProtocol) {
        self.tweetRepository = tweetRepository
        self.mainTabRouter = mainTabRouter
        self.uploadTweetRouter = uploadTweetRouter
        self.followUseCase = followUseCase
        self.tweetLikeUseCase = tweetLikeUseCase
        self.profileUseCase = profileUseCase
        self.userRepository = userRepository
        self.editUseCase = editUseCase
    }

    // MARK: - Injection

    /// TweetRouter를 외부에서 주입받습니다. (DI 방식)
    func injectTweetRouter(tweetRouter: TweetRouterProtocol) {
        self.tweetRouter = tweetRouter
    }

    // MARK: - Navigation

    /// 선택된 유저의 프로필 화면으로 이동합니다.
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController) {
        let profileController = ProfileController(router: mainTabRouter, userViewModel: userViewModel, useCase: profileUseCase, followUseCase: followUseCase, feedRouter: self, tweetLikeUseCase: tweetLikeUseCase, tweetRepository: tweetRepository, userRepository: userRepository, editUseCase: editUseCase)
        viewController.navigationController?.pushViewController(profileController, animated: true)
    }

    /// 선택된 트윗의 상세 화면으로 이동합니다.
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController) {
        guard let tweetRouter = tweetRouter else {
            print("❗️TweetRouter가 주입되지 않았습니다.")
            return
        }
        tweetRouter.navigateToTweetDetail(viewModel: tweetViewModel, userViewModel: userViewModel, from: viewController)
    }

    /// 트윗 업로드 관련 화면으로 이동합니다. (트윗 or 댓글 업로드)
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        uploadTweetRouter.navigate(to: destination, from: viewController)
    }

    /// 프로필 수정 화면으로 이동합니다. (탭바 외부에서 사용)
    func naivgateToEditProfile(userViewModel: UserViewModel, editProfileHeaderViewModel: EditProfileHeaderViewModel, editProfileViewModel: EditProfileViewModel, from viewController: UIViewController, onProfileEdited: @escaping (UserModelProtocol) -> Void) {
        let editProfileController = EditProfileController(router: self, userViewModel: userViewModel, editProfileHeaderViewModel: editProfileHeaderViewModel, viewModel: editProfileViewModel)
        editProfileController.onProfileEdited = onProfileEdited
        viewController.navigationController?.pushViewController(editProfileController, animated: true)
    }

    /// 현재 화면 dismiss (모달 닫기 등)
    func dismiss(from viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }

    /// 현재 화면 pop (NavigationController 스택에서 뒤로가기)
    func popNav(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
