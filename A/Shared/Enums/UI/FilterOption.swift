//
//  FilterOption.swift
//  A
//
//

import UIKit

enum FilterOption: Int, CaseIterable, CustomStringConvertible {
    case tweets
    case replies
    case likes

    var description: String {
        get {
            switch self {
            case .tweets:
                return "Tweets"
            case .replies:
                return "Tweets & Replies"
            case .likes:
                return "Likes"
            }
        }
    }
}

