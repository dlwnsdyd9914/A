//
//  NotificationRepository.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

final class NotificationRepository : NotificationRepositoryProtocol {


    private let service: NotificationService

    init(service: NotificationService) {
        self.service = service
    }

    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void) {
        service.fetchNotifications(completion: completion)
    }
    

}
