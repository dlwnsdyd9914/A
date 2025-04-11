//
//  FeedViewModel.swift
//  A
//
//  Created by 이준용 on 4/11/25.
//

import UIKit

final class FeedViewModel {

    private let logoutUseCase: LogoutUseCaseProtocol

    init(logoutUseCase: LogoutUseCaseProtocol) {
        self.logoutUseCase = logoutUseCase
    }

    var onLogutSuccess: (() -> Void)?
    var onLogoutFail: ((String) -> Void)?

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


}
