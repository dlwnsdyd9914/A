//
//  UserServiceError.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

enum UserServiceError: LocalizedError {
    case userNotFound
    case dataParsingError

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "유저 정보가 없습니다."
        case .dataParsingError:
            return "데이터 연결에 실패했습니다."
        }
    }

    var message: String {
        errorDescription ?? "알 수 없는 오류가 발생했습니다."
    }
}
