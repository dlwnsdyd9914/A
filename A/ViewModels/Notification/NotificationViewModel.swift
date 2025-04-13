//
//  NotificationViewModel.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

final class NotificationViewModel {

    private let useCase: NotificationUseCaseProtocol

    init(useCase: NotificationUseCaseProtocol) {
        self.useCase = useCase
    }

    private(set) var notifications = [NotificationItem]() {
        didSet {
            onFeatchNotification?()
        }
    }

    var onFeatchNotification: (() -> Void)?
    var onFetchNotificationFail: ((Error) -> Void)?


    func fetchNotifications() {
        useCase.fetchNotifications { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let notifications):
                self.notifications = notifications
            case .failure(let error):
                self.onFetchNotificationFail?(error)
            }
        }
    }


}
