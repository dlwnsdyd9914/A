//
//  ProfileViewModel.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

final class ProfileViewModel {


    private let repository: TweetRepositoryProtocol

    init(repository: TweetRepositoryProtocol) {
        self.repository = repository
    }

    var selectedFilter: FilterOption = .tweets


    var selectedTweet = [Tweet]()
    var replies = [Tweet]()

    var onSuccessSelectedFetchTweet: (() -> Void)?
    var onFailSelectedFetchTweet: ((Error) -> Void)?

    func selectedFetchTweet(uid: String){

        self.selectedTweet.removeAll()




        repository.selectFetchTweet(uid: uid) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let tweet):
                self.selectedTweet.append(tweet)
                self.selectedTweet.sort(by: {$0.timeStamp > $1.timeStamp})
                self.onSuccessSelectedFetchTweet?()
            case .failure(let error):
                self.onFailSelectedFetchTweet?(error)
            }
        }


    }
}
