//
//  ProfileUseCase.swift
//  A
//
//  Created by 이준용 on 4/15/25.
//

import UIKit

/// Profile 화면에서 사용되는 트윗 관련 비즈니스 로직을 담당하는 유즈케이스입니다.
///
/// - 역할:
///     - 특정 유저의 트윗, 좋아요 트윗, 답글 트윗을 가져오는 기능을 추상화하고 제공합니다.
///     - 트윗 데이터 패칭은 내부적으로 `TweetRepositoryProtocol`에 위임합니다.
///
/// - 주요 사용처:
///     - `ProfileViewModel`
///
/// - 설계 의도:
///     - 트윗 조회 관련 기능을 ViewModel에서 분리하여, 명확한 역할 분담과 테스트 가능성 향상을 목표로 합니다.
///     - 해당 유즈케이스는 읽기(read-only) 전용으로 동작합니다.
final class ProfileUseCase: ProfileUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: TweetRepositoryProtocol

    // MARK: - Initializer

    init(repository: TweetRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// 유저가 작성한 트윗을 모두 가져옵니다.
    /// - Parameters:
    ///   - uid: 조회할 유저의 UID
    ///   - completion: 결과로 트윗 하나씩 반환 (콜렉션은 ViewModel에서 수집)
    func selectFetchTweets(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        repository.selectFetchTweet(uid: uid, completion: completion)
    }

    /// 유저가 좋아요를 누른 트윗을 하나 조회합니다.
    /// - Parameters:
    ///   - uid: 조회할 유저의 UID
    ///   - completion: 결과로 트윗 하나 또는 nil 반환
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void)) {
        repository.fetchTweetLikes(uid: uid, completion: completion)
    }

    /// 유저가 남긴 답글 트윗을 하나 조회합니다.
    /// - Parameters:
    ///   - uid: 조회할 유저의 UID
    ///   - completion: 결과로 트윗 하나씩 반환 (콜렉션은 ViewModel에서 수집)
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        repository.fetchReplies(uid: uid, completion: completion)
    }
}
