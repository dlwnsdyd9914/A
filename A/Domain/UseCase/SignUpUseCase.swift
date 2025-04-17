//
//  SignUpUseCase.swift
//  A
//
//

import UIKit

/// 회원가입 로직을 처리하는 유즈케이스입니다.
///
/// - 역할:
///     - 사용자로부터 받은 가입 정보(이메일, 비밀번호, 이름, 프로필 이미지 등)를 인증 저장소에 전달합니다.
///     - `AuthRepository`를 통해 Firebase 등의 백엔드 서비스와 통신합니다.
///
/// - 주요 사용처:
///     - `RegisterViewModel`
///     - 회원가입 화면에서 유저 정보를 입력하고 가입 요청을 보낼 때 사용됩니다.
///
/// - 사용 이유:
///     - ViewModel이 직접 Repository를 호출하지 않도록 분리하여 SRP 원칙을 지키기 위함
///     - 유닛 테스트, DI, 로직 재사용에 유리한 구조 설계
final class SignUpUseCase: SignUpUseCaseProtocol {

    // MARK: - Dependencies

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initializer

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Public Methods

    /// 회원가입 요청을 처리합니다.
    /// - Parameters:
    ///   - email: 이메일 주소
    ///   - password: 비밀번호
    ///   - username: 사용자 이름
    ///   - fullname: 전체 이름
    ///   - profileImage: 프로필 이미지
    ///   - completion: 가입 완료 후 결과 콜백
    func signUp(email: String, password: String, username: String, fullname: String, profileImage: UIImage, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        authRepository.signUp(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage, completion: completion)
    }
}
