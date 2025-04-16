//
//  ProfileFilterItemViewModel.swift
//  A
//
//

import Foundation

/// 프로필 필터 셀(ProfileFilterCell)에 대응되는 뷰모델입니다.
/// - 역할: 개별 필터 옵션(FilterOption)에 대한 선택 상태 관리 및 UI 업데이트 트리거
/// - 사용처: ProfileFilterView 내의 셀(View)에서 바인딩하여 선택 상태에 따라 UI 조정
final class ProfileFilterItemViewModel {

    /// 현재 필터 셀의 선택 여부
    var isSelected: Bool {
        didSet {
            onFilterStatus?(isSelected)
        }
    }

    /// 필터 옵션 종류 (예: .tweets, .replies, .likes)
    let selectedFilterOption: FilterOption

    /// 선택 상태 변경 시 호출되는 클로저 (바인딩용)
    var onFilterStatus: ((Bool) -> Void)?

    // MARK: - Initializer

    /// 필터 셀 뷰모델 초기화
    /// - Parameters:
    ///   - filterOption: 현재 셀에 대응되는 필터 타입
    ///   - isSelected: 초기 선택 여부
    init(filterOption: FilterOption, isSelected: Bool) {
        self.selectedFilterOption = filterOption
        self.isSelected = isSelected
    }

    // MARK: - Functions

    /// 외부에서 선택 상태를 업데이트할 때 호출
    /// - Parameter isSelected: 선택 여부
    func updateSelectionStatus(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
