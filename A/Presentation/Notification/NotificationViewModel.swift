//
//  NotificationViewModel.swift
//  A
//
//

import UIKit

/// 알림 리스트 화면을 위한 뷰모델입니다.
/// - 역할: 알림 목록 데이터를 패치하고 UI에 바인딩
/// - 데이터: [NotificationItem]을 정렬하여 보관
/// - 바인딩: 패치 완료 및 실패에 대한 클로저 제공
final class NotificationViewModel {

    // MARK: - Properties

    /// 알림 관련 유즈케이스
    private let useCase: NotificationUseCaseProtocol

    /// 전체 알림 리스트 (내림차순 정렬됨)
    private(set) var notifications = [NotificationItem]() {
        didSet {
            onFeatchNotification?()
        }
    }

    // MARK: - Output Closures

    /// 알림 패치 성공 시 호출됨
    var onFeatchNotification: (() -> Void)?

    /// 알림 패치 실패 시 호출됨
    var onFetchNotificationFail: ((Error) -> Void)?

    // MARK: - Initializer

    init(useCase: NotificationUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - Public Methods

    /// 서버에서 알림 목록을 가져와 정렬 후 저장
    func fetchNotifications() {
        useCase.fetchNotifications { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let notifications):
                /// 알림 시간 기준 내림차순 정렬
                let sortedItems = notifications.sorted { $0.notification.timestamp > $1.notification.timestamp }
                self.notifications = sortedItems
            case .failure(let error):
                self.onFetchNotificationFail?(error)
            }
        }
    }
}
