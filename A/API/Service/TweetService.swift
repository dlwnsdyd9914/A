//
//  TweetService.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit
import Firebase

final class TweetService {

    typealias CompletionHandler = (Result<Tweet, TweetServiceError>) -> Void


    func uploadTweet(caption: String, completion: @escaping (Result<Void, TweetServiceError>) -> Void) {
        let date = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(.unknown))
            return
        }

        let values: [String: Any] = [
            "caption": caption,
            "timestamp": date,
            "likes": 0,
            "retweets": 0,
            "uid": uid
        ]

        FirebasePath.tweets.childByAutoId().updateChildValues(values) { error, ref in
            if let error = error {
                completion(.failure(.failedToUpload))
                return
            }

            guard let tweetId = ref.key else { return }

            FirebasePath.userTweets.child(uid).updateChildValues([tweetId: 1])
            completion(.success(()))
        }
    }
}
