//
//  TweetUploadUseCase.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class UploadTweetUseCase: UploadTweetUseCaseProtocol {

    


    private let repository: TweetRepositoryProtocol

    init(tweetRepository: TweetRepositoryProtocol) {
        self.repository = tweetRepository
    }
    func uploadNewTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        repository.uploadTweet(caption: caption, type: .tweet, completion: completion)
    }

    func uploadReply(caption: String, to tweet:  TweetModelProtocol, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        repository.uploadTweet(caption: caption, type: .reply(tweet), completion: completion)
    }

    
    
}
