//
//  UserFactory.swift
//  A
//
//

import UIKit
import Firebase

/// Firebase에서 UID를 기반으로 유저 데이터를 생성하는 팩토리 클래스입니다.
///
/// - 역할:
///     - UID를 기반으로 Firebase Database에서 사용자 정보를 조회하고, `User` 객체로 변환합니다.
///
/// - 주요 사용처:
///     - `UserService` 내부에서 Firebase 데이터 파싱 시 사용
///     - `TweetService`, `NotificationUseCase`, `UserRepository` 등에서 사용자 정보가 필요한 경우 직접 호출
///
/// - 설계 이유:
///     - `User` 생성 로직을 별도의 팩토리로 분리함으로써 SRP(단일 책임 원칙)를 만족하고,
///       Firebase 파싱 로직 중복 제거 및 테스트 용이성을 확보
struct UserFactory {

    /// Firebase Realtime Database에서 UID로 사용자 데이터를 조회하고 User 객체로 반환합니다.
    ///
    /// - Parameters:
    ///   - uid: 조회할 Firebase 상의 사용자 UID
    ///   - completion: 조회 결과 콜백 (성공 시 `User`, 실패 시 `.dataParsingError`)
    static func fetchUser(uid: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        FirebasePath.users.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }

            let user = User(uid: snapshot.key, dictionary: value)
            completion(.success(user))
        }
    }
}
