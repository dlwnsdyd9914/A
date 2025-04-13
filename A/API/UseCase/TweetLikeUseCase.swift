//
//  TweetLikeUseCase.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class TweetLikeUseCase: TweetLikeUseCaseProtocol {

    

    

    

    private let repository: TweetRepositoryProtocol

    init(repository: TweetRepositoryProtocol) {
        self.repository = repository
    }

    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void) {
        repository.likesTweet(tweet: tweet, completion: completion)
    }

    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        repository.likesStatus(tweet: tweet, completion: completion)
    }

}
