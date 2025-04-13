//
//  ActionSheetOptions.swift
//  A
//
//  Created by 이준용 on 4/13/25.
//

import Foundation

enum ActionSheetOptions: CustomStringConvertible {


    case follow(UserModelProtocol)
    case unfollow(UserModelProtocol)
    case report
    case delete

    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.userName)"
        case .unfollow(let user):
            return "Unfollow @\(user.userName)"
        case .report:
            return "Report Tweet"
        case .delete:
            return "Delete Tweet"
        }
    }
}
