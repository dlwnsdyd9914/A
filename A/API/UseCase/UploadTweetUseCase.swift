//
//  UploadTweetUseCase.swift
//  A
//
//

import UIKit

/// 트윗 업로드 및 리플 업로드 관련 유즈케이스입니다.
///
/// - 역할:
///     - 새 트윗 작성 또는 특정 트윗에 대한 리플 작성 기능을 담당합니다.
///     - 트윗 업로드 시 필요한 구체적 처리 로직은 Repository에 위임합니다.
///
/// - 주요 사용처:
///     - `UploadTweetViewModel`
///     - `UploadTweetController`
///
/// - 비즈니스 목적:
///     - 트윗 업로드 로직을 ViewModel에서 분리함으로써 테스트 가능성과 유지보수성을 높입니다.
final class UploadTweetUseCase: UploadTweetUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: TweetRepositoryProtocol

    // MARK: - Initializer

    init(tweetRepository: TweetRepositoryProtocol) {
        self.repository = tweetRepository
    }

    // MARK: - Public Methods

    /// 새 트윗을 업로드합니다.
    /// - Parameters:
    ///   - caption: 트윗 본문
    ///   - completion: 업로드 결과 콜백
    func uploadNewTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        repository.uploadTweet(caption: caption, type: .tweet, completion: completion)
    }

    /// 특정 트윗에 리플을 업로드합니다.
    /// - Parameters:
    ///   - caption: 리플 내용
    ///   - tweet: 리플 대상 트윗
    ///   - completion: 업로드 결과 콜백
    func uploadReply(caption: String, to tweet: TweetModelProtocol, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        repository.uploadTweet(caption: caption, type: .reply(tweet), completion: completion)
    }
}
