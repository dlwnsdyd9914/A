//
//  AuthServiceError.swift
//  A
//
//  Created by 이준용 on 4/10/25.
//

import UIKit

enum AuthServiceError: LocalizedError {
    case failedToCreateUser
    case invalidImageData
    case failedToUploadImage
    case failedToGetImageURL
    case failedToSaveUserData
    case faildToLogin
    case faildToLogout

    var errorDescription: String? {
        switch self {
        case .failedToCreateUser:
            return "사용자 생성에 실패했습니다."
        case .invalidImageData:
            return "잘못된 이미지 데이터입니다."
        case .failedToUploadImage:
            return "이미지 업로드에 실패했습니다."
        case .failedToGetImageURL:
            return "이미지 URL을 가져오는 데 실패했습니다."
        case .failedToSaveUserData:
            return "사용자 정보를 저장하지 못했습니다."
        case .faildToLogin:
            return "사용자 로그인에 실패했습니다."
        case .faildToLogout:
            return "사용자 로그아웃에 실패했습니다."
        }
    }

    var message: String {
        errorDescription ?? "알 수 없는 오류가 발생했습니다."
    }
}

