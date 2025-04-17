//
//  NotificationUseCaseProtocol.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

protocol NotificationUseCaseProtocol {
    
    func fetchNotifications(completion: @escaping (Result<[NotificationItem], NotificationServiceError>) -> Void)
}
