//
//  ProfileFilterViewModel.swift
//  A
//
//

import Foundation

/// 프로필 화면의 필터 탭에서 사용되는 뷰모델입니다.
/// - 역할: 현재 선택된 필터 상태(selectedIndex)와 가능한 필터 목록(filterOptions)을 관리합니다.
/// - 사용처: `ProfileFilterView`, `ProfileHeader` 등 필터 인터페이스 관련 뷰에서 활용됩니다.
final class ProfileFilterViewModel {

    /// 현재 선택된 필터 인덱스 (기본값: 0)
    var selectedIndex: Int = 0

    /// 필터 옵션 목록 (기본값: FilterOption.allCases)
    let filterOptions: [FilterOption]

    // MARK: - Initializer

    /// 필터 뷰모델 초기화
    /// - Parameters:
    ///   - filterOptions: 필터 항목 배열 (기본값: FilterOption.allCases)
    ///   - selectedIndex: 초기 선택 인덱스 (기본값: 0)
    init(filterOptions: [FilterOption] = FilterOption.allCases, selectedIndex: Int = 0) {
        self.filterOptions = filterOptions
        self.selectedIndex = selectedIndex
    }
}
