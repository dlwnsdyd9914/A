//
//  TweetRepositoryProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol TweetRepositoryProtocol {
    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void)
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
}
