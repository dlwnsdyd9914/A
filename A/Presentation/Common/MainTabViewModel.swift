//
//  MainTabViewModel.swift
//  A
//
//

import UIKit

/// 메인 탭 컨트롤러에서 현재 로그인된 사용자 정보를 관리하는 뷰모델
/// - 목적: 로그인 직후 사용자 정보를 fetch하여, 의존 뷰에 전달하는 역할 수행
/// - 구성: 유저 페칭 및 바인딩 콜백 제공
final class MainTabViewModel {

    // MARK: - Output Properties

    /// 현재 로그인된 사용자 모델 (페칭 성공 시 바인딩됨)
    private(set) var user: User? {
        didSet {
            guard let user else { return }
            self.onFetchUser?(user)
        }
    }

    // MARK: - Dependencies

    /// 유저 정보를 가져오는 레포지토리
    private let userRepository: UserRepositoryProtocol

    // MARK: - Initializer

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    // MARK: - Callbacks

    /// 유저 정보를 성공적으로 가져왔을 때 호출됨
    var onFetchUser: ((User) -> Void)?

    /// 유저 정보 페칭에 실패했을 때 호출됨
    var onFetchUserFail: ((String) -> Void)?

    // MARK: - Functions

    /// 로그인된 사용자 정보 비동기 요청
    /// - 성공: `user` 프로퍼티에 저장되고, `onFetchUser` 콜백 트리거됨
    /// - 실패: 에러 메시지를 `onFetchUserFail` 콜백으로 전달
    func fetchUser() {
        userRepository.fetchUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                self.onFetchUserFail?(error.message)
            }
        }
    }
}
