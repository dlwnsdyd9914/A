//
//  TweetLikeUseCase.swift
//  A
//
//

import UIKit

/// 트윗 좋아요 기능에 대한 유즈케이스 로직을 담당합니다.
///
/// - 역할:
///     - 좋아요 처리 및 상태 확인 기능을 비즈니스 로직 단에서 관리합니다.
///     - `TweetRepository`를 통해 실제 데이터 처리 작업을 위임합니다.
///
/// - 주요 사용처:
///     - `TweetViewModel` → 좋아요 버튼 탭 시 유즈케이스 호출
///     - `TweetHeaderViewModel`, `NotificationCellViewModel` 등에서도 확장 가능
///
/// - 구성 요소:
///     - 좋아요/좋아요 취소 처리 (`likesTweet`)
///     - 로그인 유저가 특정 트윗에 좋아요 눌렀는지 여부 확인 (`likesStatus`)
final class TweetLikeUseCase: TweetLikeUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: TweetRepositoryProtocol

    // MARK: - Initializer

    init(repository: TweetRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// 특정 트윗에 좋아요/좋아요 취소를 수행합니다.
    /// - Parameters:
    ///   - tweet: 좋아요를 누를 대상 트윗
    ///   - completion: 성공 여부와 함께 현재 좋아요 상태 전달
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        repository.likesTweet(tweet: tweet, completion: completion)
    }

    /// 현재 로그인 유저가 해당 트윗에 좋아요를 눌렀는지 상태를 확인합니다.
    /// - Parameters:
    ///   - tweet: 대상 트윗
    ///   - completion: 좋아요 여부 반환
    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        repository.likesStatus(tweet: tweet, completion: completion)
    }
}
