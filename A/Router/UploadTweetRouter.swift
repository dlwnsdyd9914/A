//
//  UploadTweetRouter.swift
//  A
//
//

import UIKit

/// 트윗 업로드(작성/댓글) 화면으로의 이동 및 닫기 처리를 담당하는 라우터입니다.
///
/// - 역할:
///     - 트윗 작성(Upload) 및 리플 작성 화면으로의 전환을 담당
///     - 모달 또는 푸시 방식의 화면 종료 처리 제공
///
/// - 주요 사용처:
///     - FeedRouter, TweetRouter 등에서 트윗 업로드 목적에 따라 사용
///
/// - 설계 이유:
///     - 화면 전환 방식을 외부에서 주입받아 다양한 전환 스타일 대응 가능
///     - UploadTweetController 구성 로직을 분리하여 뷰컨트롤러의 SRP 보장
final class UploadTweetRouter: UploadTweetRouterProtocol {

    // MARK: - Dependencies

    private let uploadTweetUseCase: UploadTweetUseCaseProtocol

    // MARK: - Initializer

    init(uploadTweetUseCase: UploadTweetUseCaseProtocol) {
        self.uploadTweetUseCase = uploadTweetUseCase
    }

    // MARK: - Navigation

    /// 업로드 트윗 화면을 목적에 맞게 화면에 표시합니다.
    /// - Parameters:
    ///   - destination: 업로드 목적 (트윗 or 리플)
    ///   - viewController: 현재 화면 기준 (from)
    func navigate(to destination: TweetDestination, from viewController: UIViewController) {
        switch destination {
        case .uploadTweet(let userViewModel):
            let vc = UploadTweetController(router: self, userViewModel: userViewModel, configuration: .tweet, presentaionStyle: .modal, uploadTweetUseCase: uploadTweetUseCase)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            viewController.present(nav, animated: true)

        case .uploadReply(userViewModel: let userViewModel, tweet: let tweet):
            let vc = UploadTweetController(router: self, userViewModel: userViewModel, configuration: .reply(tweet), presentaionStyle: .push, uploadTweetUseCase: uploadTweetUseCase)
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Dismiss

    /// 업로드 화면을 스타일에 따라 닫습니다.
    /// - Parameters:
    ///   - style: 닫기 방식 (modal or push)
    ///   - viewController: 현재 표시된 뷰컨트롤러
    func close(style presentationStyle: UploadTweetPresentationStyle, from viewController: UIViewController) {
        switch presentationStyle {
        case .modal:
            viewController.dismiss(animated: true)
        case .push:
            viewController.navigationController?.popViewController(animated: true)
        }
    }
}
