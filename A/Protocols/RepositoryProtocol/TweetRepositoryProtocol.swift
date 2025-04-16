//
//  TweetRepositoryProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol TweetRepositoryProtocol {
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Result<Void, TweetServiceError>) -> Void)
    func fetchAllTweets(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
    func fetchTweet(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
    func fetchTweetReplies(tweetId: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Result<Bool, TweetServiceError>) -> Void)
    func likesStatus(tweet: any TweetModelProtocol, completion: @escaping (Bool) -> Void)
    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet?) -> Void))
    func fetchReplies(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void)
}
