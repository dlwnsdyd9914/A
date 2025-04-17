//
//  FetchTweetWithRepliesUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

protocol FetchTweetWithRepliesUseCaseProtocol {
    func fetchTweetWithReplies(completion: @escaping (Result<([Tweet], [Tweet]), TweetServiceError>) -> Void)
    func fetchTweetsWithRepliesForProfile(uid: String, completion: @escaping (Result<(Tweet, [Tweet]), TweetServiceError>) -> Void)
}
