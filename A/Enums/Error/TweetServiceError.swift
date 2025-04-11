//
//  TweetServiceError.swift
//  A
//
//  Created by 이준용 on 4/12/25.
//

import UIKit

enum TweetServiceError: LocalizedError {
    case emptyCaption
    case failedToUpload
    case failedToFetch
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyCaption:
            return "내용을 입력해주세요."
        case .failedToUpload:
            return "트윗 업로드에 실패했습니다. 잠시 후 다시 시도해주세요."
        case .failedToFetch:
            return "트윗을 불러오는 데 실패했습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

    var message: String {
        errorDescription ?? "알 수 없는 오류가 발생했습니다."
    }
}

