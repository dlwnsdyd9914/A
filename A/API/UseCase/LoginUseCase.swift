//
//  LoginUseCase.swift
//  A
//
//

import UIKit

/// 이메일과 비밀번호를 통한 로그인 로직을 처리하는 유즈케이스입니다.
///
/// - 역할:
///     - 이메일/비밀번호 입력값 유효성 검사 후 로그인 요청을 수행합니다.
///     - 실제 인증 로직은 `AuthRepository`에 위임됩니다.
///
/// - 주요 사용처:
///     - `LoginViewModel`
///     - 또는 인증 플로우에서 로그인 기능이 필요한 뷰모델에서 호출됩니다.
///
/// - 사용 이유:
///     - ViewModel에서 인증 도메인 로직을 분리하여 SRP를 지키기 위함입니다.
///     - 테스트, 유지보수, 의존성 주입에 유리한 구조를 갖습니다.
final class LoginUseCase: LoginUseCaseProtocol {

    // MARK: - Dependencies

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initializer

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Public Methods

    /// 로그인 요청을 수행합니다.
    /// - Parameters:
    ///   - email: 사용자의 이메일
    ///   - password: 비밀번호
    ///   - completion: 로그인 성공/실패에 대한 결과 콜백
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        // ✅ 기본 유효성 검사
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(.faildToLogin))
            return
        }

        print("🔐 [로그인 요청] \(email)")
        authRepository.login(email: email, password: password, completion: completion)
    }
}
