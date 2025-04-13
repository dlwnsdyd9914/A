//
//  NotificationServiceError.swift
//  A
//
//  Created by 이준용 on 4/14/25.
//

import UIKit

enum NotificationServiceError: Error {
    case unauthorized          // 사용자 인증 실패 (uid 없음)
    case dataNotFound          // 스냅샷 value가 없거나 파싱 불가
    case decodingFailed        // 모델 초기화 실패 (필수값 없음 등)
    case firebaseError(Error)  // Firebase 자체 에러 (옵셔널)
}
