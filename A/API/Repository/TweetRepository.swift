//
//  TweetRepository.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class TweetRepository: TweetRepositoryProtocol {



    private let service: TweetService

    init(service: TweetService) {
        self.service = service
    }

    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        service.uploadTweet(caption: caption, type: type, completion: completion)
    }


    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchAllTweets(completion: completion)
    }

    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.selectFetchTweets(uid: uid, completion: completion)
    }

    func fetchTweetReplies(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchTweetReplies(tweetId: tweetId, completion: completion)
    }
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        service.likesTweet(tweet: tweet, completion: completion)
    }
    func likesStatus(tweet: any TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        service.likesStatus(tweet: tweet, completion: completion)
    }
    func fetchTweet(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchTweet(tweetId: tweetId, completion: completion)
    }


}
