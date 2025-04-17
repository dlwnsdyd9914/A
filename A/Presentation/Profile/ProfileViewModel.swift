//
//  ProfileViewModel.swift
//  A
//
//

import UIKit

/// 프로필 화면에서 사용자의 트윗, 리플, 좋아요 트윗 데이터를 관리하는 뷰모델입니다.
/// - 역할: 선택된 필터에 따라 해당 데이터를 useCase를 통해 비동기 fetch
/// - 구성: 필터별로 세 가지 배열(selectedTweet, replies, likedTweets)을 구분하여 보관
/// - 뷰와의 연결: 클로저를 통해 UI 업데이트 트리거 제공
final class ProfileViewModel {

    // MARK: - UseCases

    /// 트윗/좋아요/리플 패치 로직을 캡슐화한 유즈케이스
    private let useCase: ProfileUseCaseProtocol

    // MARK: - Initializer

    init(useCase: ProfileUseCaseProtocol){
        self.useCase = useCase
    }

    // MARK: - Filter 상태 및 데이터

    /// 현재 선택된 필터 상태
    var selectedFilter: FilterOption = .tweets

    /// 선택된 유저의 일반 트윗 목록
    private var selectedTweet = [Tweet]() {
        didSet { onFetchFilterSuccess?() }
    }

    /// 선택된 유저가 작성한 리플 목록
    private var replies = [Tweet]() {
        didSet { onFetchFilterSuccess?() }
    }

    /// 선택된 유저가 좋아요한 트윗 목록
    var likedTweets = [Tweet]() {
        didSet { onFetchFilterSuccess?() }
    }

    /// 현재 필터에 해당하는 데이터 소스
    var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return selectedTweet
        case .replies: return replies
        case .likes: return likedTweets
        }
    }

    // MARK: - Output Closures

    /// 필터 선택 시 해당 데이터 로딩 완료 후 호출
    var onSuccessSelectedFetchTweet: (() -> Void)?
    var onFailSelectedFetchTweet: ((Error) -> Void)?
    var onFetchFilterSuccess: (() -> Void)?

    // MARK: - Public Methods

    /// 필터 기준에 따라 트윗 데이터를 fetch합니다.
    /// - Parameter uid: 사용자 고유 ID
    func selectedFetchTweet(uid: String) {
        self.removeFilter(filterOption: selectedFilter)

        switch selectedFilter {
        case .tweets:
            fetchUserTweet(uid: uid)
        case .replies:
            fetchReplies(uid: uid)
        case .likes:
            fetchTweetLikes(uid: uid)
        }
    }

    // MARK: - Tweets

    /// 사용자의 일반 트윗 데이터를 가져옵니다.
    private func fetchUserTweet(uid: String) {
        useCase.selectFetchTweets(uid: uid) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tweet):
                if !self.selectedTweet.contains(where: { $0.tweetId == tweet.tweetId }) {
                    self.selectedTweet.append(tweet)
                }
                self.selectedTweet.sort(by: { $0.timeStamp > $1.timeStamp })

            case .failure(let error):
                handleError(error)
            }
        }
    }

    // MARK: - Likes

    /// 사용자가 좋아요한 트윗을 가져옵니다.
    private func fetchTweetLikes(uid: String) {
        useCase.fetchTweetLikes(uid: uid) { [weak self] likedTweet in
            guard let self, let likedTweet else {
                print("❌ 좋아요 트윗이 nil임 (패치 실패 또는 잘못된 트윗 ID)")
                return
            }

            if !self.likedTweets.contains(where: { $0.tweetId == likedTweet.tweetId }) {
                self.likedTweets.append(likedTweet)
                print("✅ 좋아요 트윗 추가됨: \(likedTweet.tweetId)")
            } else {
                print("⚠️ 이미 존재하는 트윗: \(likedTweet.tweetId)")
            }

            self.likedTweets.sort(by: { $0.timeStamp > $1.timeStamp })
        }
    }

    // MARK: - Replies

    /// 사용자가 남긴 리플 데이터를 가져옵니다.
    private func fetchReplies(uid: String) {
        useCase.fetchReplies(uid: uid) { [weak self ] result in
            guard let self else { return }

            switch result {
            case .success(let reply):
                if !self.replies.contains(where: { $0.timeStamp == reply.timeStamp }) {
                    self.replies.append(reply)
                }
                self.replies.sort(by: { $0.timeStamp > $1.timeStamp })

            case .failure(let error):
                handleError(error)
            }
        }
    }

    // MARK: - Helpers

    /// 현재 선택된 필터에 해당하는 데이터를 초기화합니다.
    func removeFilter(filterOption: FilterOption) {
        switch filterOption {
        case .tweets:
            selectedTweet.removeAll()
        case .replies:
            replies.removeAll()
        case .likes:
            likedTweets.removeAll()
        }
    }

    /// 공통 에러 핸들링 출력
    private func handleError(_ error: TweetServiceError) {
        switch error {
        case .emptyCaption:
            print("⚠️ 실패: 캡션이 비어 있습니다.")
        case .failedToUpload:
            print("🚫 실패: 트윗 업로드에 실패했습니다.")
        case .failedToFetch:
            print("📡 실패: 트윗을 가져오는 데 실패했습니다.")
        case .failedToDelete:
            print("🗑️ 실패: 트윗 삭제에 실패했습니다.")
        case .failedToLike:
            print("💔 실패: 좋아요 처리 중 오류가 발생했습니다.")
        case .failedToUnlike:
            print("💔 실패: 좋아요 취소 중 오류가 발생했습니다.")
        case .failedTransaction:
            print("💥 실패: Firebase 트랜잭션에 실패했습니다.")
        case .unauthorized:
            print("🔐 실패: 인증되지 않은 접근입니다.")
        case .unknown:
            print("❓ 실패: 알 수 없는 오류가 발생했습니다.")
        }
    }
}
