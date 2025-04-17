//
//  LogoutUseCase.swift
//  A
//
//

import UIKit

/// 로그아웃 기능을 수행하는 유즈케이스입니다.
///
/// - 역할:
///     - 인증 상태 관리 중 '로그아웃' 기능을 담당합니다.
///     - 실제 Firebase 로그아웃 처리는 AuthRepository에 위임합니다.
///
/// - 주요 사용처:
///     - `FeedViewModel`
///     - `MainTabViewModel`
///     - 또는 로그아웃이 필요한 모든 ViewModel에서 호출됩니다.
///
/// - 사용 이유:
///     - 인증 관련 도메인 로직(AuthService)을 추상화하고,
///       ViewModel의 책임을 줄이기 위한 유즈케이스 레이어입니다.
final class LogoutUseCase: LogoutUseCaseProtocol {

    // MARK: - Dependencies

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initializer

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Public Methods

    /// 로그아웃 기능 실행
    /// - Parameter completion: 로그아웃 성공/실패 콜백
    func logout(completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        self.authRepository.logout(completion: completion)
    }
}
