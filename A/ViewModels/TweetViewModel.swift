//
//  TweetViewModel.swift
//  A
//
//

import UIKit

/// 트윗 셀, 디테일, 댓글 등에서 사용되는 뷰모델
/// 트윗 정보 포맷팅, 좋아요 처리, 댓글 패칭, 멘션 유저 탐색 등의 역할을 담당
final class TweetViewModel: TweetViewModelProtocol {

    // MARK: - Dependencies

    private let repository: TweetRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let useCase: TweetLikeUseCaseProtocol

    // MARK: - Models

    private var tweet: TweetModelProtocol
    var userViewModel: UserViewModelProtocol

    /// 트윗에 달린 리플 목록 (성공시 didSet 통해 onRepliesFetchSuccess 호출)
    var replies = [Tweet]() {
        didSet {
            onRepliesFetchSuccess?()
        }
    }

    // MARK: - Init

    init(tweet: TweetModelProtocol, repository: TweetRepositoryProtocol, useCase: TweetLikeUseCaseProtocol, userViewModel: UserViewModelProtocol, userRepository: UserRepositoryProtocol) {
        self.tweet = tweet
        self.repository = repository
        self.useCase = useCase
        self.userViewModel = userViewModel
        self.userRepository = userRepository
    }

    // MARK: - Computed Properties

    /// 트윗 본문
    var caption: String {
        return tweet.caption
    }

    /// 트윗 작성 시점과 현재의 시간 차이 포맷 문자열
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timeStamp, to: now) ?? "2m"
    }

    /// 유저 프로필 이미지 URL
    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    /// 트윗 고유 ID
    var tweetId: String {
        return tweet.tweetId
    }

    /// 사용자 이름 + 아이디 + 시간정보 라벨 포맷 (예: Eddie @slimon . 1h)
    var infoLabel: NSAttributedString {
        let title = NSMutableAttributedString(string: tweet.user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(tweet.user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        title.append(NSAttributedString(string: " . \(timestamp)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                                                NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    /// 좋아요 버튼 이미지 (좋아요 여부에 따라 변경)
    var likeButtonImage: UIImage {
        return tweet.didLike ? UIImage.likeFilled : UIImage.like
    }

    /// 리플 헤더에서 리플 라벨 숨김 여부 판단
    var shouldHideReplyLabel: Bool {
        return !tweet.isRely
    }

    /// 리플 대상 유저 ID
    var replyingTo: String {
        return tweet.replyingTo ?? ""
    }

    /// 리플 대상 유저 라벨 포맷
    var replyText: String {
        return "→ replying to @\(replyingTo)"
    }

    // MARK: - Bindable Event 

    var onHandleCommentButton: (() -> Void)?
    var onRepliesFetchSuccess: (() -> Void)?
    var onRepliesFetchFail: ((Error) -> Void)?
    var onLikeSuccess: (() -> Void)?
    var onLikeFail: ((Error) -> Void)?
    var onTweetLikes: (() -> Void)?
    var ondidLike: ((Bool) -> Void)?
    var onMentionUserFetched: ((UserModelProtocol) -> Void)?

    // MARK: - Public Functions

    /// 현재 트윗의 유저 객체 반환
    func getUser() -> UserModelProtocol {
        return tweet.user
    }

    /// 현재 트윗 객체 반환
    func getTweet() -> TweetModelProtocol {
        return tweet
    }

    /// 좋아요 버튼 핸들러
    func handleLikeButton() {
        like()
    }

    /// 리트윗 버튼 (미구현)
    func handleRetweetButton() {
        print("Tweet retweeted: \(tweet.tweetId)")
    }

    /// 댓글 버튼 탭 이벤트 처리
    func handleCommentButton() {
        print("Comment button tapped for: \(tweet.tweetId)")
        onHandleCommentButton?()
    }

    /// 공유 버튼 탭 이벤트 처리 (미구현)
    func handleShareButton() {
        print("Share button tapped for: \(tweet.tweetId)")
    }

    /// 트윗에 달린 댓글 불러오기
    func fetchReplies() {
        repository.fetchTweetReplies(tweetId: tweetId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tweet):
                self.replies.append(tweet)
                self.replies.sort(by: { $0.timeStamp > $1.timeStamp })
                self.onRepliesFetchSuccess?()
            case .failure(let error):
                self.onRepliesFetchFail?(error)
            }
        }
    }

    /// 트윗 좋아요 처리 (UseCase 사용)
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

    /// 좋아요 여부 상태 조회
    func didLike() {
        useCase.likesStatus(tweet: tweet) { [weak self] didLike in
            guard let self else { return }
            self.tweet.didLike = didLike
            self.onLikeSuccess?()
            self.ondidLike?(didLike)
        }
    }

    /// 멘션된 유저의 username으로 유저 탐색
    func handleMention(username: String) {
        userRepository.fetchUser(username: username) { [weak self] result in
            switch result {
            case .success(let user):
                self?.onMentionUserFetched?(user)
            case .failure(let error):
                print("❌ 유저 조회 실패: \(error)")
            }
        }
    }
}
