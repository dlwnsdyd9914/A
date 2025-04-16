//
//  EditProfileOption.swift
//  A
//
//

import UIKit

enum EditProfileOption: Int, CaseIterable, CustomStringConvertible {

    case fullname
    case username
    case bio

    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        case .bio: return "Bio"
        }
    }
}
