//
//  MainTabViewModel.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit


final class MainTabViewModel {

    private(set) var user: User? {
        didSet {
            guard let user else { return }
            self.onFetchUser?(user)
        }
    }

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    var onFetchUser: ((User) -> Void)?
    var onFetchUserFail: ((String) -> Void)?

    func fetchUser() {
        userRepository.fetchUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                self.onFetchUserFail?(error.message)
            }
        }
    }
}
