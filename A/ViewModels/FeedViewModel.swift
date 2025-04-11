//
//  FeedViewModel.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class FeedViewModel {

    private let logoutUseCase: LogoutUseCaseProtocol
    private let repository: TweetRepositoryProtocol

    private(set) var allTweets: [Tweet] = []

    init(logoutUseCase: LogoutUseCaseProtocol, repository: TweetRepositoryProtocol) {
        self.logoutUseCase = logoutUseCase
        self.repository = repository
    }

    var onLogutSuccess: (() -> Void)?
    var onLogoutFail: ((String) -> Void)?
    var onFetchTweetsSuccess: (() -> Void)?
    var onFetchTweetFail: ((Error) -> Void)?



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

    func fetchAllTweets() {
        repository.fetchAllTweets { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tweet):
                self.allTweets.append(tweet)
                self.allTweets.sort(by: {$0.timeStamp > $1.timeStamp})
                self.onFetchTweetsSuccess?()
            case .failure(let error):
                print("❌ 트윗 불러오기 실패: \(error.localizedDescription)")
                self.onFetchTweetFail?(error)
            }
        }
    }

}
