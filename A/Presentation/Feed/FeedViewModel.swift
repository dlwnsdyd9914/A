//
//  FeedViewModel.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

/// 메인 피드 화면에서 사용되는 ViewModel
/// - 기능: 전체 트윗 불러오기, 로그아웃 처리 등
/// - 바인딩: 트윗 불러오기 성공/실패, 로그아웃 결과 처리 등을 클로저로 바인딩
final class FeedViewModel {

    // MARK: - Dependencies

    private let logoutUseCase: LogoutUseCaseProtocol
    private let repository: TweetRepositoryProtocol

    // MARK: - Data

    /// 전체 트윗 데이터 배열
    private(set) var allTweets: [Tweet] = []

    // MARK: - Initializer

    init(logoutUseCase: LogoutUseCaseProtocol, repository: TweetRepositoryProtocol) {
        self.logoutUseCase = logoutUseCase
        self.repository = repository
    }

    // MARK: - Bindings

    /// 로그아웃 성공 시 호출
    var onLogutSuccess: (() -> Void)?

    /// 로그아웃 실패 시 호출 (에러 메시지 전달)
    var onLogoutFail: ((String) -> Void)?

    /// 트윗 불러오기 성공 시 호출
    var onFetchTweetsSuccess: (() -> Void)?

    /// 트윗 불러오기 실패 시 호출 (에러 전달)
    var onFetchTweetFail: ((Error) -> Void)?

    // MARK: - UseCase Functions

    /// 로그아웃 요청 → 성공/실패 바인딩 클로저 호출
    func logout() {
        logoutUseCase.logout { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                self.onLogutSuccess?()
            case .failure(let error):
                self.onLogoutFail?(error.message)
            }
        }
    }

    /// 전체 트윗 데이터 fetch 요청
    /// - 트윗은 최신순으로 정렬하여 저장함
    func fetchAllTweets() {
        repository.fetchAllTweets { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tweet):
                self.allTweets.append(tweet)
                self.allTweets.sort(by: { $0.timeStamp > $1.timeStamp })
                self.onFetchTweetsSuccess?()

            case .failure(let error):
                print("❌ 트윗 불러오기 실패: \(error.localizedDescription)")
                self.onFetchTweetFail?(error)
            }
        }
    }
}
