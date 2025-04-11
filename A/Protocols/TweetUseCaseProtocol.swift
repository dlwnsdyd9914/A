//
//  TweetUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

protocol UploadTweetUseCaseProtocol {
    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void)
}
