//
//  FetchTweetWithRepliesUseCase.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class FetchTweetWithRepliesUseCase: FetchTweetWithRepliesUseCaseProtocol {
    func fetchTweetWithReplies(completion: @escaping (Result<([Tweet], [Tweet]), TweetServiceError>) -> Void) {
        
    }
    
    private let repository: TweetRepositoryProtocol

    init(repository: TweetRepositoryProtocol) {
        self.repository = repository
    }

    func fetchTweetWithReplies(completion: @escaping (Result<(Tweet, [Tweet]), TweetServiceError>) -> Void) {

//        repository.fetchAllTweets { [weak self] result in
//            guard let self else { return }
//
//            switch result {
//            case .success(let tweet):
//                self.repository.fetchTweetReplies(tweetId: tweet.tweetId) { replies in
//                    completion(.success((tweet, replies)))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
    func fetchTweetsWithRepliesForProfile(uid: String, completion: @escaping (Result<(Tweet, [Tweet]), TweetServiceError>) -> Void) {

//        repository.selectFetchTweet(uid: uid) { [weak self] result in
//            guard let self else { return }
//
//            switch result {
//            case .success(let tweet):
//                self.repository.fetchTweetReplies(tweetId: tweet.tweetId) { replies in
//                    completion(.success((tweet, replies)))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }


}

