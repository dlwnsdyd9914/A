//
//  TweetRouter.swift
//  A
//
//

import UIKit

/// 트윗 상세 화면에서 발생하는 화면 전환 및 알림 표시 등의 라우팅을 담당하는 라우터입니다.
///
/// - 역할:
///     - 트윗 상세 화면에서 유저 프로필로 이동
///     - 액션 시트(AlertSheet) 모달 표시 및 해제
///     - 알림 또는 프로필 뷰로의 라우팅을 FeedRouter에 위임
///
/// - 주요 사용처:
///     - TweetController, TweetViewModel 내 사용자 인터랙션 대응
///
/// - 설계 이유:
///     - 뷰컨트롤러 내 화면 전환 책임을 분리하여 단일 책임 원칙(SRP) 준수
///     - Alert 표시 등 UIKit 특화된 처리를 별도 모듈로 구성
final class TweetRouter: TweetRouterProtocol {

    // MARK: - Dependencies

    private let tweetRepository: TweetRepositoryProtocol
    private let tweetLikeUseCase: TweetLikeUseCaseProtocol
    private let followUseCase: FollowUseCaseProtocol
    private let feedRouter: FeedRouterProtocol
    private let userRepository: UserRepositoryProtocol

    // MARK: - Initializer

    init(tweetRepository: TweetRepositoryProtocol ,tweetLikeUseCase: TweetLikeUseCaseProtocol, followUseCase: FollowUseCaseProtocol, feedRouter: FeedRouterProtocol, userRepository: UserRepositoryProtocol) {
        self.tweetRepository = tweetRepository
        self.tweetLikeUseCase = tweetLikeUseCase
        self.followUseCase = followUseCase
        self.feedRouter = feedRouter
        self.userRepository = userRepository
    }

    // MARK: - Routing Logic

    /// 트윗 상세 화면으로 이동합니다.
    /// - Parameters:
    ///   - tweetViewModel: 트윗 뷰모델
    ///   - userViewModel: 유저 뷰모델
    ///   - viewController: 현재 기준 뷰컨트롤러
    func navigateToTweetDetail(viewModel tweetViewModel: TweetViewModel, userViewModel: UserViewModel, from viewController: UIViewController) {
        let tweetDetailVC = TweetController(viewModel: tweetViewModel, repository: tweetRepository, router: self, useCase: tweetLikeUseCase, followUseCase: followUseCase, userViewModel: userViewModel, userRepository: userRepository
        )
        viewController.navigationController?.pushViewController(tweetDetailVC, animated: true)
    }

    /// 커스텀 액션 시트를 모달로 표시합니다.
    /// - Parameters:
    ///   - viewModel: 액션 시트 뷰모델
    ///   - viewController: 기준 뷰컨트롤러
    func presentActionSheet(viewModel: ActionSheetViewModel, from viewController: UIViewController) {
        let alert = CustomAlertController(viewModel: viewModel, router: self)
        alert.modalPresentationStyle = .overFullScreen
        viewController.present(alert, animated: true)
    }

    /// 커스텀 액션 시트를 해제합니다.
    /// - Parameters:
    ///   - alert: 표시된 커스텀 알럿 뷰컨트롤러
    ///   - bool: 애니메이션 여부
    func dismissAlert(_ alert: CustomAlertController, animated bool: Bool) {
        /// weak 참조를 통해 메모리 릭 방지: 애니메이션 도중 알럿이 해제되더라도 순환 참조 방지
        weak var weakAlert = alert
        UIView.animate(withDuration: 0.3, animations: {
            weakAlert?.blackView.alpha = 0
            weakAlert?.tableView.transform = CGAffineTransform(translationX: 0, y: weakAlert?.tableViewHeight ?? 0)
        }, completion: { _ in
            weakAlert?.dismiss(animated: bool)
        })
    }

    /// 유저 프로필 화면으로 이동합니다.
    /// - Parameters:
    ///   - userViewModel: 유저 뷰모델
    ///   - viewController: 현재 기준 뷰컨트롤러
    func navigateToUserProfile(userViewModel: UserViewModel, from viewController: UIViewController) {
        feedRouter.navigateToUserProfile(userViewModel: userViewModel, from: viewController)
    }
}
