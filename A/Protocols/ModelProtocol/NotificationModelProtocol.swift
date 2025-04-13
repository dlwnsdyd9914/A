//
//  NotificationModelProtocol.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

protocol NotificationModelProtocol {
    var id: String { get }
    var timestamp: Date { get }
    var type: NotificationType? { get set }
    var caption: String? { get }
    var tweetID: String? { get }    
    var fromUid: String { get }
    var isRead: Bool { get set }
}
