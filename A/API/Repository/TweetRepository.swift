//
//  TweetRepository.swift
//  A
//
//

import UIKit

/// 트윗 관련 데이터를 담당하는 Repository 클래스입니다.
///
/// - 역할:
///     - TweetService와 UseCase 사이에서 데이터 요청을 중개합니다.
///     - 트윗 업로드, 좋아요, 댓글 등 모든 트윗 관련 작업에 대한 추상화 레이어 제공
///
/// - 주요 사용처:
///     - `TweetLikeUseCase`, `ProfileUseCase`, `UploadTweetUseCase`, `TweetViewModel` 등 트윗 관련 유즈케이스 및 뷰모델
///
/// - 설계 이유:
///     - 클린 아키텍처 구조에서 서비스 로직과 도메인 계층을 분리하여 테스트 가능성과 유지보수성을 확보
final class TweetRepository: TweetRepositoryProtocol {

    // MARK: - Dependencies

    private let service: TweetService

    // MARK: - Initializer

    init(service: TweetService) {
        self.service = service
    }

    // MARK: - Tweet Upload

    /// 트윗 또는 댓글을 업로드합니다.
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        service.uploadTweet(caption: caption, type: type, completion: completion)
    }

    // MARK: - Fetch Tweets

    /// 전체 트윗 목록을 가져옵니다.
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchAllTweets(completion: completion)
    }

    /// 특정 유저의 트윗을 선택적으로 가져옵니다.
    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.selectFetchTweets(uid: uid, completion: completion)
    }

    /// 특정 트윗 ID에 해당하는 리플(댓글)을 불러옵니다.
    func fetchTweetReplies(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchTweetReplies(tweetId: tweetId, completion: completion)
    }

    /// 특정 트윗에 대한 좋아요/좋아요 취소 처리를 수행합니다.
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        service.likesTweet(tweet: tweet, completion: completion)
    }

    /// 현재 로그인 사용자가 해당 트윗을 좋아요 눌렀는지 여부를 확인합니다.
    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        service.likesStatus(tweet: tweet, completion: completion)
    }

    /// 특정 트윗 ID를 기준으로 트윗 단건을 패치합니다.
    func fetchTweet(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchTweet(tweetId: tweetId, completion: completion)
    }

    /// 로그인 유저가 좋아요 누른 트윗을 패치합니다.
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void)) {
        service.fetchTweetLikes(uid: uid, completion: completion)
    }

    /// 특정 유저가 남긴 리플을 가져옵니다.
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchReplies(uid: uid, completion: completion)
    }
}
