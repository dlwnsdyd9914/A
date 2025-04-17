//
//  TweetLikeUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

protocol TweetLikeUseCaseProtocol {
    func likesTweet(tweet:  TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void)
    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void)
}
