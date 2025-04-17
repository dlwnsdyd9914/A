//
//  TextFieldType.swift
//  A
//
//

import UIKit

enum TextFieldType: String, CustomStringConvertible{


    case email = "Email"
    case password = "Password"
    case fullname = "Fullname"
    case username = "Username"

    var description: String {
        switch self {
        case .email: return "Email"
        case .password: return "Password"
        case .fullname: return "Fullname"
        case .username: return "Username"
        }
    }
}
