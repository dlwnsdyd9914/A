//
//  TweetViewModel.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import UIKit

final class TweetViewModel: TweetViewModelProtocol {

    private let repository: TweetRepositoryProtocol
    private let useCase: TweetLikeUseCaseProtocol

    private var tweet: TweetModelProtocol

    var replies = [Tweet]() {
        didSet {
            onRepliesFetchSuccess?()
        }
    }

    init(tweet: TweetModelProtocol, repository: TweetRepositoryProtocol, useCase: TweetLikeUseCaseProtocol) {
        self.tweet = tweet
        self.repository = repository
        self.useCase = useCase

    }

    var caption: String {
        return tweet.caption
    }

    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timeStamp, to: now) ?? "2m"
    }

    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    var tweetId: String {
        return tweet.tweetId
    }

    var infoLabel: NSAttributedString {
        let title = NSMutableAttributedString(string: tweet.user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(tweet.user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        title.append(NSAttributedString(string: " . \(timestamp)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                                                NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    var likeButtonImage: UIImage {
        return tweet.didLike ? UIImage.likeFilled : UIImage.like
    }



    var onHandleCommentButton: (() -> Void)?
    var onRepliesFetchSuccess: (() -> Void)?
    var onRepliesFetchFail: ((Error) -> Void)?
    var onLikeSuccess: (() -> Void)?
    var onLikeFail: ((Error) -> Void)?
    var onTweetLikes: (() -> Void)?
    var ondidLike: ((Bool) -> Void)?

    func getUser() -> UserModelProtocol {
        return tweet.user
    }

    func getTweet() -> TweetModelProtocol {
        return tweet
    }

    func handleLikeButton() {
        like()
    }


    func handleRetweetButton() {

        print("Tweet retweeted: \(tweet.tweetId)")
    }

    func handleCommentButton() {
        print("Comment button tapped for: \(tweet.tweetId)")
        onHandleCommentButton?()
    }

    func handleShareButton() {
        print("Share button tapped for: \(tweet.tweetId)")
    }

    func fetchReplies() {
        repository.fetchTweetReplies(tweetId: tweetId) {[weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tweet):
                self.replies.append(tweet)
                self.replies.sort(by: {$0.timeStamp > $1.timeStamp})
                self.onRepliesFetchSuccess?()
            case .failure(let error):
                self.onRepliesFetchFail?(error)
            }
        }
    }

    func like() {
        useCase.likesTweet(tweet: tweet) { [weak self] result  in
            guard let self else { return }
            switch result {
            case .success(let didLike):
                tweet.didLike = didLike
                self.onLikeSuccess?()
                self.onTweetLikes?()
            case .failure(let error):
                self.onLikeFail?(error)
            }
        }
    }

    func didLike() {
        useCase.likesStatus(tweet: tweet) {[weak self] didLike in
            guard let self else { return }
            self.tweet.didLike = didLike
            self.onLikeSuccess?()
            self.ondidLike?(didLike)

            
        }
    }


}
