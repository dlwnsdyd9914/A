//
//  NotificationRepository.swift
//  A
//
//

import UIKit

/// 알림 데이터를 가져오는 Repository 클래스입니다.
///
/// - 역할:
///     - NotificationService를 통해 알림 데이터를 가져오고, UseCase 레이어에 전달합니다.
///     - Service와 UseCase 사이에서 의존성 분리를 위한 중간 추상 계층 역할을 수행합니다.
///
/// - 주요 사용처:
///     - `NotificationUseCase` → 알림 데이터를 비즈니스 로직에 맞게 처리할 때 호출됨
///
/// - 설계 이유:
///     - 클린 아키텍처의 Repository 패턴을 따르며, UseCase가 Service에 직접 접근하지 않도록 추상화를 유지
///     - 테스트 및 모킹(Mock) 시 Service를 대체할 수 있는 유연한 구조 확보
final class NotificationRepository: NotificationRepositoryProtocol {

    // MARK: - Dependencies

    private let service: NotificationService

    // MARK: - Initializer

    init(service: NotificationService) {
        self.service = service
    }

    // MARK: - Functions

    /// Firebase에서 알림 리스트를 가져오는 함수입니다.
   /// - Parameter completion: 알림 데이터 결과 콜백
    func fetchNotifications(completion: @escaping (Result<[Notification], NotificationServiceError>) -> Void) {
        service.fetchNotifications(completion: completion)
    }
}
