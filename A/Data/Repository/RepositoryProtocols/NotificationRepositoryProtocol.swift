//
//  NotificationRepositoryProtocol.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import Foundation

protocol NotificationRepositoryProtocol {
    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void)

}
