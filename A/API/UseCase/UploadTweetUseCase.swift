//
//  TweetUploadUseCase.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class UploadTweetUseCase: UploadTweetUseCaseProtocol {


    private let tweetRepository: TweetRepositoryProtocol

    init(tweetRepository: TweetRepositoryProtocol) {
        self.tweetRepository = tweetRepository
    }

    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        tweetRepository.uploadTweet(caption: caption, completion: completion)
    }
    
    
}
