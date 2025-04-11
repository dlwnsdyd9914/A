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

    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        service.uploadTweet(caption: caption, completion: completion)
    }
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        service.fetchAllTweets(completion: completion)
    }

    
}
