//
//  ProfileUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/15/25.
//

import UIKit

protocol ProfileUseCaseProtocol {
    func selectFetchTweets(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void))
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
}
