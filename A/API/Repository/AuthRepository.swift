//
//  AuthRepository.swift
//  A
//
//

import UIKit

/// 인증 관련 기능을 도메인 계층에 제공하는 리포지토리 클래스입니다.
///
/// - 역할:
///     - `AuthService`를 래핑하여 회원가입, 로그인, 로그아웃 기능을 외부에서 사용할 수 있도록 추상화합니다.
///
/// - 주요 사용처:
///     - `LoginUseCase`, `SignUpUseCase`, `LogoutUseCase` 등 인증 도메인 로직을 처리하는 UseCase 계층에서 사용됩니다.
///
/// - 설계 이유:
///     - Firebase 기반 인증 로직을 도메인 계층과 분리하여 SRP(단일 책임 원칙)를 지키고,
///       나중에 Firebase가 아닌 다른 인증 방식으로 교체 시에도 유연하게 대처할 수 있도록 구성했습니다.
final class AuthRepository: AuthRepositoryProtocol {

    // MARK: - Dependencies

    private let service: AuthService

    // MARK: - Initializer

    init(service: AuthService) {
        self.service = service
    }

    // MARK: - Authentication Methods

    /// 회원가입 처리
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.createUser(email: email, password: password, profileImage: profileImage, username: username, fullname: fullname, completion: completion)
    }

    /// 로그인 처리
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.login(email: email, password: password, completion: completion)
    }

    /// 로그아웃 처리
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        service.logout(completion: completion)
    }
}
